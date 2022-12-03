{ config, options, lib, pkgs, modulesPath, ... }:

let
  inherit (builtins) toString;
  domain = config.networking.domain;
  passwordManagerDomain = "pass.${domain}";

  # This should be set from service module from nixpkgs.
  vaultwardenUser = config.users.users.vaultwarden.name;

  # However, this is set on our own.
  vaultwardenDbName = "vaultwarden";
in
{
  imports = [
    ./hardware-configuration.nix

    # The users for this host.
    (lib.getUser "nixos" "admin")
    (lib.getUser "nixos" "plover")

    # Several profile from nixpkgs.
    "${modulesPath}/profiles/headless.nix"
    "${modulesPath}/profiles/hardened.nix"
  ];

  networking.domain = "foodogsquared.one";

  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ./secrets/secrets.yaml;
      };
      getSecrets = secrets:
        lib.mapAttrs'
          (secret: config:
            lib.nameValuePair
              "plover/${secret}"
              ((getKey secret) // config))
          secrets;
    in
    getSecrets (let
      giteaUserGroup = config.users.users."${config.services.gitea.user}".group;

      # It is hardcoded but as long as the module is stable that way.
      vaultwardenUserGroup = config.users.groups.vaultwarden.name;
    in {
      "ssh-key" = {};
      "gitea/db/password".owner = giteaUserGroup;
      "gitea/smtp/password".owner = giteaUserGroup;
      "vaultwarden/env".owner = vaultwardenUserGroup;
      "borg/patterns/keys" = {};
      "borg/password" = {};
    });

  # All of the keys required to deploy the secrets. Don't know how to make the
  # GCP KMS key work though without manually going into the instance and
  # configure it there.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  profiles.server = {
    enable = true;
    headless.enable = true;
    hardened-config.enable = true;
    cleanup.enable = true;
  };

  # DNS-related settings. This is nice for automating them putting DNS records
  # and other types of stuff.
  security.acme.defaults = {
    dnsProvider = "porkbun";
    credentialsFile = config.sops.secrets."plover/lego/env".path;
  };

  services.openssh.hostKeys = [{
    path = config.sops.secrets."plover/ssh-key".path;
    type = "ed25519";
  }];

  # Some additional dependencies for this system.
  environment.systemPackages = with pkgs; [
    asciidoctor # This is needed for additional markup for Gitea.
  ];

  # The main server where it will tie all of the services in one neat little
  # place.
  services.nginx = {
    enable = true;
    enableReload = true;
    package = pkgs.nginxMainline;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Server blocks with no forcing of SSL are static sites so it is pretty
    # much OK.
    virtualHosts = {
      # Vaultwarden instance.
      "${passwordManagerDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations = let
          address = config.services.vaultwarden.config.ROCKET_ADDRESS;
          port = config.services.vaultwarden.config.ROCKET_PORT;
          websocketPort = config.services.vaultwarden.config.WEBSOCKET_PORT;
        in {
          "/" = {
            proxyPass = "http://${address}:${toString port}";
            proxyWebsockets = true;
          };

          "/notifications/hub" = {
            proxyPass = "http://${address}:${toString websocketPort}";
            proxyWebsockets = true;
          };

          "/notifications/hub/negotiate" = {
            proxyPass = "http://${address}:${toString port}";
            proxyWebsockets = true;
          };
        };
      };

      # Gitea instance.
      "code.${config.networking.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.gitea.httpPort}";
        };
      };
    };
  };

  # Enable database services that is used in all of the services here so far.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;

    # There's no database and user checks for Vaultwarden service.
    ensureDatabases = [ vaultwardenDbName ];
    ensureUsers = [
      {
        name = vaultwardenUser;
        ensurePermissions = {
          "DATABASE ${vaultwardenDbName}" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # My code forge.
  services.gitea = {
    enable = true;
    appName = "foodogsquared's code forge";
    database = {
      type = "postgres";
      passwordFile = config.sops.secrets."plover/gitea/db/password".path;
    };
    lfs.enable = true;
    mailerPasswordFile = config.sops.secrets."plover/gitea/smtp/password".path;

    settings = {
      "repository.pull_request" = {
        WORK_IN_PROGRESS_PREFIXES = "WIP:,[WIP],DRAFT,[DRAFT]";
        ADD_CO_COMMITTERS_TRAILERS = true;
      };

      ui = {
        EXPLORE_PAGING_SUM = 15;
        GRAPH_MAX_COMMIT_NUM = 200;
      };

      "ui.meta" = {
        AUTHOR = "foodogsquared's code forge";
        DESCRIPTION = ''
          foodogsquared's personal Git forge.
          Mainly personal projects and some archived and mirrored codebases.
        '';
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
        RENDER_COMMANDS = "asciidoc --out-file=- -";
        IS_INPUT_FILE = false;
      };

      # Mailer service.
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtp";
        SMTP_ADDRESS = "smtp.sendgrid.net";
        SMTP_PORT = 587;
        USER = "apikey";
        FROM = "Gitea";
        ENVELOPE_FROM = "gitea@foodogsquared.one";
        SEND_AS_PLAIN_TEXT = true;
      };

      # Well, collaboration between forges is nice...
      federation.ENABLED = true;

      # Enable mirroring feature...
      mirror.ENABLED = true;

      other = {
        SHOW_FOOTER_VERSION = true;
        ENABLE_SITEMAP = true;
        ENABLE_FEED = true;
      };
    };
  };

  # An alternative implementation of Bitwarden written in Rust. The project
  # being written in Rust is a insta-self-hosting material right there.
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.secrets."plover/vaultwarden/env".path;
    config = {
      DOMAIN = "https://${passwordManagerDomain}";

      # Configuring the server.
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      # Ehh... It's only a few (or even one) users anyways so nah. Since this
      # instance will not configure SMTP server, this pretty much means
      # invitation is only via email at this point.
      SHOW_PASSWORD_HINT = false;

      # Configuring some parts of account management which is almost
      # nonexistent because this is just intended for me (at least right now).
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      INVITATIONS_ALLOWED = true;

      # Notifications...
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_PORT = 3012;
      WEBSOCKET_ADDRESS = "0.0.0.0";

      # Enabling web vault with whatever nixpkgs comes in.
      WEB_VAULT_ENABLED = true;

      # Configuring the database. Take note it is required to create a password
      # for the user.
      DATABASE_URL = "postgresql://${vaultwardenUser}@/${vaultwardenDbName}";
    };
  };

  # Of course, what is a server without a backup? A professionally-handled
  # production system so we can act like one.
  services.borgbackup.jobs.host-backup = let
    patterns = [
      config.sops.secrets."plover/borg/patterns/keys".path
    ];
  in {
    compression = "zstd,11";
    dateFormat = "+%F-%H-%M-%S-%z";
    doInit = true;
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets."plover/borg/password".path}";
    };
    extraCreateArgs = lib.concatStringsSep " "
      (builtins.map (patternFile: "--patterns-from ${patternFile}") patterns);
    extraInitArgs = "--make-parent-dirs";
    # We're setting it since it is required plus we're replacing all of them
    # with patterns anyways.
    paths = [];
    persistentTimer = true;
    preHook = ''
      extraCreateArgs="$extraCreateArgs --stats"
    '';
    prune = {
      keep = {
        weekly = 4;
        monthly = 12;
        yearly = 6;
      };
    };
    repo = "cr6pf13r@cr6pf13r.repo.borgbase.com:repo";
    startAt = "monthly";
    environment.BORG_RSH = "ssh -i ${config.sops.secrets."plover/ssh-key".path}";
  };

  programs.ssh.extraConfig = ''
    Host *.repo.borgbase.com
     IdentityFile ${config.sops.secrets."plover/ssh-key".path}
  '';

  system.stateVersion = "22.11";
}
