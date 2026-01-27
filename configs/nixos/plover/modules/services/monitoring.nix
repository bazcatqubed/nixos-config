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
  cfg = hostCfg.services.monitoring;

  prometheusExports = config.services.prometheus.exporters;
in
{
  options.hosts.plover.services.monitoring.enable = lib.mkEnableOption "preferred monitoring stack";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.prometheus = {
          enable = true;

          exporters = {
            node = {
              enable = true;
              enabledCollectors = [ "systemd" ];
            };
          };

          scrapeConfigs = [
            {
              job_name = config.networking.hostName;
              static_configs = [
                {
                  targets = [ "127.0.0.1:${builtins.toString prometheusExports.node.port}" ];
                }
              ];
            }
          ];
        };
      }
    ]
  );
}
