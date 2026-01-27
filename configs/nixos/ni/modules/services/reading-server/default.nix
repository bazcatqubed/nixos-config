# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  foodogsquaredLib,
  ...
}:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.reading-server;
in
{
  options.hosts.ni.services.reading-server.enable = lib.mkEnableOption "reading server";

  config = lib.mkIf cfg.enable {
    state.ports.kavita.value = 6797;

    sops.secrets.kavita-token = foodogsquaredLib.sops-nix.getAsOneSecret ./secrets.bin;

    services.kavita = {
      enable = true;
      tokenKeyFile = config.sops.secrets.kavita-token.path;
      settings.Port = config.state.ports.kavita.value;
    };

    hosts.ni.services.backup.globalPaths = [
      config.services.kavita.dataDir
    ];
  };
}
