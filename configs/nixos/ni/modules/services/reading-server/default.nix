{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.reading-server;
in
{
  options.hosts.ni.services.reading-server.enable =
    lib.mkEnableOption "reading server";

  config = lib.mkIf cfg.enable {
    sops.secrets.kavita-token = foodogsquaredLib.sops-nix.getAsOneSecret ./secrets.bin;

    services.kavita = {
      enable = true;
      tokenKeyFile = config.sops.secrets.kavita-token.path;
    };

    hosts.ni.services.backup.globalPaths = [
      config.services.kavita.dataDir
    ];
  };
}
