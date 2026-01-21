# All of the non-modular-arguments are going to be put here (mainly things from
# the nixpkgs instance).
{ formats }:

{
  config,
  options,
  lib,
  ...
}:

let
  cfg = config.vouch-proxy;
  settingsFormat = formats.yaml { };
in
{
  _class = "service";

  options.vouch-proxy = {
    package = lib.mkOption {
      description = "Package to use for Vouch Proxy service.";
      defaultText = "The `vouch-proxy` package provided from the nixpkgs instance.";
      type = lib.types.package;
    };

    extraArguments = lib.mkOption {
      type = with lib.types; listOf str;
      description = "List of additional arguments to be applied to the Vouch Proxy service.";
      default = [ ];
      example = lib.literalExpression ''
        [
          "-loglevel" "error"
        ]
      '';
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        Settings to be applied for the specific service. This value is ignored
        if {option}`vouch-proxy.settingsFile` is set to a non-null value.
      '';
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
      type = lib.types.path;
      default = settingsFormat.generate "vouch-proxy-settings" cfg.settings;
      description = ''
        Settings file to be used for the service. If the value is `null`, it
        generates one from the given value of `settings`.
      '';
    };
  };

  config = {
    process.argv = [
      (lib.getExe config.vouch-proxy.package)
      "-c"
      cfg.settingsFile
    ]
    ++ cfg.extraArguments;
  }
  // (lib.optionalAttrs (options ? systemd)) {
    systemd.mainExecStart = config.systemd.lib.escapeSystemdExecArgs config.process.argv;

    systemd.service = {
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;

        Restart = "on-failure";
        RestartSec = 5;

        PrivateTmp = true;
        PrivateDevices = true;

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@keyring"
          "~@module"
          "~@privileged"
          "~@reboot"
        ];
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
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
      };
    };
  };
}
