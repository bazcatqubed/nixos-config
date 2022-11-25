{ config, options, lib, pkgs, ... }:

let
  domain = "foodogsquared.one";
  passwordManagerDomain = "vault.${domain}";
  codeForgeDomain = "forge.${domain}";
in
{
  imports = [
    (lib.getUser "nixos" "plover")
  ];

  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ./secrets/secrets.yaml;
      };
      getSecrets = keys:
        lib.listToAttrs (lib.lists.map
          (secret:
            lib.nameValuePair
              "plover/${secret}"
              (getKey secret))
          keys);
    in
    getSecrets [
      "ssh-key"
      "gitea/db/password"
    ];

  # Be sure to upload this manually. (It's this really a good idea?)
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  services.nginx = {
    enable = true;
    enableReload = true;
    package = pkgs.nginxMainline;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      # These are just websites that are already deployed.
      "www.${domain}" = {
        locations."/" = {
          proxyPass = "https://foodogsquared.netlify.app";
        };
      };
      "wiki.${domain}" = {
        locations."/" = {
          proxyPass = "https://foodogsquared-wiki.netlify.app";
        };
      };
      "search.${domain}" = {
        locations."/" = {
          proxyPass = "https://search.brave.com";
        };
      };

      # Vaultwarden instance.
      "${passwordManagerDomain}" = {
        http2 = true;
        forceSSL = true;
        enableACME = true;
        locations = let
          port = config.services.vaultwarden.config.ROCKET_PORT;
          websocketPort = config.services.vaultwarden.config.WEBSOCKET_PORT;
        in {
          "/" = {
            proxyPass = "http://localhost:${toString port}";
            proxyWebsockets = true;
          };

          "/notifications/hub" = {
            proxyPass = "http://localhost:${toString websocketPort}";
            proxyWebsockets = true;
          };

          "/notifications/hub/negotiate" = {
            proxyPass = "http://localhost:${toString port}";
            proxyWebsockets = true;
          };
        };
      };

      "${codeForgeDomain}" = {
        http2 = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:${config.services.gitea.httpPort}";
        };
      };
    };
  };

  # Time to harden...
  profiles.system.hardened-config.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@foodogsquared.one";

    certs = {
      "${passwordManagerDomain}".keyType = "rs2048";
      "${codeForgeDomain}" = {};
    };
  };

  # Some additional dependencies for this system.
  environment.systemPackages = with pkgs; [
    asciidoctor
  ];

  # My code forge.
  services.gitea = {
    inherit domain;
    enable = true;
    appName = "foodogsquared's code forge";
    # TODO: Use postgresql later
    database = {
      passwordFile = config.sops.secrets."plover/gitea/db/password".path;
      #type = "postgres";
    };
    lfs.enable = true;
    #mailerPasswordFile = config.sops.secrets."plover/gitea/smtp/password".path;
    rootUrl = "http://${codeForgeDomain}";

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
      WEB_VAULT_FOLDER = "${pkgs.vaultwarden-vault}/share/vaultwarden";
    };
  };

  system.stateVersion = "22.11";
}
