# My code forge service of choice. I'm pretty excited for the federation
# feature in particular to see how this plays out. It might not be toppling
# over the popular services but it is interesting to see new spaces for this
# one.
{ config, lib, pkgs, ... }:

let
  codeForgeDomain = "code.${config.networking.domain}";

  giteaDatabaseUser = config.services.gitea.user;
in
{
  services.gitea = {
    enable = true;
    appName = "foodogsquared's code forge";
    database = {
      type = "postgres";
      passwordFile = config.sops.secrets."plover/gitea/db/password".path;
    };

    # Allow Gitea to take a dump.
    dump = {
      enable = true;
      interval = "weekly";
    };

    # There are a lot of services in port 3000 so we'll change it.
    lfs.enable = true;

    mailerPasswordFile = config.sops.secrets."plover/gitea/smtp/password".path;

    # You can see the available configuration options at
    # https://docs.gitea.io/en-us/config-cheat-sheet/.
    settings = {
      server = {
        ROOT_URL = "https://${codeForgeDomain}";
        HTTP_PORT = 8432;
        DOMAIN = codeForgeDomain;
      };

      "repository.pull_request" = {
        WORK_IN_PROGRESS_PREFIXES = "WIP:,[WIP],DRAFT,[DRAFT]";
        ADD_CO_COMMITTERS_TRAILERS = true;
      };

      ui = {
        DEFAULT_THEME = "auto";
        EXPLORE_PAGING_SUM = 15;
        GRAPH_MAX_COMMIT_NUM = 200;
      };

      "ui.meta" = {
        AUTHOR = "foodogsquared's code forge";
        DESCRIPTION = "foodogsquared's personal projects and some archived and mirrored codebases.";
        KEYWORDS = "foodogsquared,gitea,self-hosted";
      };

      # It's a personal instance so nah...
      service.DISABLE_REGISTRATION = true;

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        DEFAULT_PRIVATE = "public";
        DEFAULT_PRIVATE_PUSH_CREATE = true;
      };

      "markup.asciidoc" = {
        ENABLED = true;
        NEED_POSTPROCESS = true;
        FILE_EXTENSIONS = ".adoc,.asciidoc";
        RENDER_COMMAND = "${pkgs.asciidoctor}/bin/asciidoctor --embedded --out-file=- -";
        IS_INPUT_FILE = false;
      };

      # Mailer service.
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtp+starttls";
        SMTP_ADDRESS = "smtp.sendgrid.net";
        SMTP_PORT = 587;
        USER = "apikey";
        FROM = "bot+gitea@foodogsquared.one";
        SEND_AS_PLAIN_TEXT = true;
        SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
      };

      # Reduce the logs to be filled with. You also have to keep in mind this
      # to be configured with fail2ban.
      log.LEVEL = "Warn";

      # Well, collaboration between forges is nice...
      federation.ENABLED = true;

      # Enable mirroring feature...
      mirror.ENABLED = true;

      # Session configuration.
      session.COOKIE_SECURE = true;

      # Some more database configuration.
      database.SCHEMA = config.services.gitea.user;

      # Run various periodic services.
      "cron.update_mirrors".SCHEDULE = "@every 3h";

      other = {
        SHOW_FOOTER_VERSION = true;
        ENABLE_SITEMAP = true;
        ENABLE_FEED = true;
      };
    };
  };

  # Disk space is always assumed to be limited so we're really only limited
  # with 2 dumps.
  systemd.services.gitea-dump.preStart = lib.mkAfter ''
    ${pkgs.findutils}/bin/find ${lib.escapeShellArg config.services.gitea.dump.backupDir} \
      -mtime 14 -maxdepth 1 -type f -delete
  '';

  # Making sure this plays nicely with the database service of choice. Take
  # note, we're mainly using secure schema usage pattern here as described from
  # the PostgreSQL documentation at
  # https://www.postgresql.org/docs/15/ddl-schemas.html#DDL-SCHEMAS-PATTERNS.
  services.postgresql = {
    ensureUsers = [{
      name = config.services.gitea.user;
      ensurePermissions = {
        "SCHEMA ${config.services.gitea.user}" = "ALL PRIVILEGES";
      };
    }];
  };

  # Setting up Gitea for PostgreSQL secure schema usage.
  systemd.services.gitea = {
    path = [ config.services.postgresql.package ];

    # Gitea service module will have to set up certain things first which is
    # why we have to go first.
    preStart =
      let
        giteaBin = "${lib.getBin config.services.gitea.package}/bin/gitea";
        giteaAdminUsername = lib.escapeShellArg "foodogsquared";
      in
      lib.mkMerge [
        (lib.mkBefore ''
          # Setting up the appropriate schema for PostgreSQL secure schema usage.
          psql -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name='${giteaDatabaseUser}';" \
            grep -q 1 || psql -tAc "CREATE SCHEMA IF NOT EXISTS AUTHORIZATION ${giteaDatabaseUser};"
        '')

        (lib.mkAfter ''
          # Setting up the administrator account automated.
          ${giteaBin} admin user list --admin | grep -q ${giteaAdminUsername} \
            || ${giteaBin} admin user create \
              --username ${giteaAdminUsername} --email foodogsquared@${config.networking.domain} \
              --random-password --random-password-length 76 --admin
        '')
      ];
  };

  # Attaching it altogether with the reverse proxy of choice.
  services.nginx.virtualHosts."${codeForgeDomain}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.gitea.settings.server.HTTP_PORT}";
    };
  };

  # Configuring fail2ban for this service which thankfully has a dedicated page
  # at https://docs.gitea.io/en-us/fail2ban-setup/.
  services.fail2ban.jails = {
    gitea = ''
      enabled = true
      backend = systemd
      filter = gitea[journalmatch='_SYSTEMD_UNIT=gitea.service + _COMM=gitea']
      maxretry = 8
    '';
  };

  environment.etc = {
    "fail2ban/filter.d/gitea.conf".text = ''
      [Includes]
      before = common.conf

      # Thankfully, Gitea also has a dedicated page for configuring fail2ban
      # for the service at https://docs.gitea.io/en-us/fail2ban-setup/
      [Definition]
      failregex = ^.*(Failed authentication attempt|invalid credentials|Attempted access of unknown user).* from <HOST>
      ignoreregex =
    '';
  };

  # Customizing Gitea which you can see more details at
  # https://docs.gitea.io/en-us/customizing-gitea/. We're just using
  # systemd-tmpfiles to make this work which is pretty convenient.
  systemd.tmpfiles.rules =
    let
      # To be used similarly to $GITEA_CUSTOM variable.
      giteaCustomDir = "${config.services.gitea.stateDir}/custom";
    in
    [
      "L+ ${giteaCustomDir}/templates/home.tmpl - - - - ${../../files/gitea/home.tmpl}"
      "L+ ${giteaCustomDir}/public/img/logo.svg - - - - ${../../files/gitea/logo.svg}"
      "L+ ${giteaCustomDir}/public/img/logo.png - - - - ${../../files/gitea/logo.png}"
    ];
}
