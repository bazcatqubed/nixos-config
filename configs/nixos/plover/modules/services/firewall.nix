# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostCfg = config.hosts.plover;
  cfg = hostCfg.services.firewall;
in
{
  options.hosts.plover.services.firewall.enable = lib.mkEnableOption "firewall setup";

  config = lib.mkIf cfg.enable {
    networking = {
      nftables.enable = true;
      firewall = {
        enable = true;

        # Secure Shells
        allowedTCPPorts = [ 22 ];
        allowedUDPPorts = [ 22 ];
      };
    };
  };
}
