{ config, lib, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.rss-reader;

  port = config.state.ports.miniflux.value;
in {
  options.hosts.ni.services.rss-reader.enable =
    lib.mkEnableOption "preferred RSS reader service";

  config = lib.mkIf cfg.enable {
    sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets.yaml {
      "miniflux/admin".restartUnits = [ config.systemd.services.miniflux.name ];
    };

    state.ports.miniflux.value = 9640;

    services.miniflux = {
      enable = true;
      adminCredentialsFile = config.sops.secrets."miniflux/admin".path;
      config = {
        LISTEN_ADDR = "127.0.0.1:${builtins.toString port}";
        BASE_URL = "http://rss.ni.local";
        CREATE_ADMIN = true;
        METRICS_COLLECTOR = lib.mkIf hostCfg.services.monitoring.enable "1";
      };
    };

    services.nginx.virtualHosts."rss.ni.local" = {
      locations."/".proxyPass = "http://ni.local:${builtins.toString port}";
    };

    # Just make sure you execute this script as `miniflux` helper especially
    # that it is configured with PostgreSQL.
    wrapper-manager.packages.miniflux-helper = {
      wrappers.miniflux-helper = {
        arg0 = lib.getExe' config.services.miniflux.package "miniflux";
        env = lib.mapAttrs (_: value: { value = builtins.toString value; })
          config.services.miniflux.config;
      };
    };
  };
}
