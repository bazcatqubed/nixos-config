{ config, lib, pkgs, utils, ... }:

let
  cfg = config.services.vouch-proxy;
  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.vouch-proxy = {
    enable = lib.mkEnableOption "Vouch Proxy, a proxy for SSO and OAuth/OIDC logins";

    package = lib.mkPackageOption pkgs "vouch-proxy" { };

    settings = lib.mkOption {
      description = ''
        Configuration to be passed to Vouch Proxy.

        ::: {.note}
        For settings with sensitive values like client secrets, you can specify
        a `_secret` attribute with a path value. In the final version of the
        generated settings, the key will have the value with the content of the
        specified path.
        :::
      '';
      type = settingsFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          vouch = {
            listen = "127.0.0.1";
            port = 30746;
            domains = [ "gitea.example.com" ];
            allowAllUsers = true;
            jwt.secret._secret = "/path/to/jwt-secret";
            session.key._secret = "/path/to/session-key-secret";
          };

          oauth = {
            provider = "github";
            client_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
            client_secret._secret = "/path/to/secret";
            auth_url = "https://gitea.example.com/login/oauth/authorize";
            token_url = "https://gitea.example.com/login/oauth/access_token";
            user_info_url = "https://gitea.example.com/api/v1/user?token=";
            callback_url = "https://example.com/auth";
          };
        }
      '';
    };

    settingsFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      defaultText = lib.literalExpression "settingsFile";
      description = ''
        The path of the configuration file. If `null`, it uses the
        filepath from NixOS-generated settings.
      '';
      example = lib.literalExpression "/etc/vouch-proxy/config.yml";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.vouch-proxy = let
      settingsFile' = "/var/lib/vouch-proxy/config.yml";
    in
    {
      preStart = if (cfg.settings != { } && cfg.settingsFile == null)
        then ''
          ${pkgs.writeScript
            "vouch-proxy-replace-secrets"
            (utils.genJqSecretsReplacementSnippet cfg.settings settingsFile')}
        ''
        else ''
          install -Dm0600 "${cfg.settingsFile}" "${settingsFile'}"
        '';
      script = "${lib.getExe' cfg.package "vouch-proxy"} -config ${settingsFile'}";
      serviceConfig = {
        DynamicUser = true;
        User = "vouch-proxy";
        Group = "vouch-proxy";

        Restart = "on-failure";
        RestartSec = 5;
        StartLimitInterval = "60s";
        StartLimitBurst = 3;

        LockPersonality = true;
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectHostname = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";

        SystemCallFilter = [ "@system-service" ];
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";

        RuntimeDirectory = "vouch-proxy";
        StateDirectory = "vouch-proxy";

        # Restricting what capabilities this service has.
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

        # Limit this service to Unix sockets and IPs.
        RestrictAddressFamilies = [
          "AF_LOCAL"

          # The internet class families.
          "AF_INET"
          "AF_INET6"
        ];

        # Restrict what namespaces it can create which is none.
        RestrictNamespaces = true;
      };
    };
  };
}
