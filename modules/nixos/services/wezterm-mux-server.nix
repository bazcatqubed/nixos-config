{ config, lib, pkgs, ... }:

let
  cfg = config.services.wezterm-mux-server;
in
{
  options.services.wezterm-mux-server = {
    enable = lib.mkEnableOption "Wezterm mux server";

    package = lib.mkOption {
      type = lib.types.package;
      description = ''
        The package containing the {command}`wezterm-mux-server` binary.
      '';
      default = pkgs.wezterm;
      defaultText = "pkgs.wezterm";
    };

    configFile = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        The path to the configuration file. For more information, you can see
        [its section for setting up multiplexing](https://wezfurlong.org/wezterm/multiplexing.html).
      '';
      default = null;
      defaultText = "null";
      example = lib.literalExpression "./wezterm-mux-server.lua";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.wezterm-mux-server = {
      description = "Wezterm mux server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${lib.getExe' cfg.package "wezterm-mux-server"} ${lib.optionalString (cfg.configFile != null) "--config-file ${cfg.configFile}"}";

      # Give it some tough love.
      serviceConfig = {
        User = config.users.users.wezterm.name;
        Group = config.users.groups.wezterm.name;

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

        RuntimeDirectory = "wezterm";
        CacheDirectory = "wezterm";
        StateDirectory = "wezterm";

        # Restricting what capabilities this service has.
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

        # Restrict what address families this service can interact with.
        # Wezterm mux server mostly expects it to interact with the internet
        # families and makes use of Unix sockets.
        RestrictAddressFamilies = [
          # Practically required as it uses Unix sockets.
          "AF_LOCAL"

          # The internet class families.
          "AF_INET"
          "AF_INET6"
        ];

        # Restrict what namespaces it can create which is none.
        RestrictNamespaces = true;
      };
    };

    users.users.wezterm = {
      description = "Wezterm system user";
      home = "/var/lib/wezterm";
      createHome = true;
      group = config.users.groups.wezterm.name;
      isSystemUser = true;
    };

    users.groups.wezterm = { };
  };
}
