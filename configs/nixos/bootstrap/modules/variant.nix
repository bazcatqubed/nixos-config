# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

let
  hostCfg = config.hosts.bootstrap;
  cfg = hostCfg.variant;
in
{
  options.hosts.bootstrap.variant = lib.mkOption {
    type = with lib.types; nullOr (enum [ "graphical" ]);
    description = ''
      Indicates the variant of the configuration to be included.
    '';
    default = "graphical";
    example = lib.literalExpression "null";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "graphical") {
      # Use my desktop environment configuration without the apps just to make the
      # closure size smaller.
      workflows = {
        enable = [ "one.foodogsquared.AHappyGNOME" ];
        workflows."one.foodogsquared.AHappyGNOME" = {
          extraApps = lib.mkForce [ ];
        };
      };

      # Install the web browser of course. What would be a graphical installer
      # without one, yes?
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-foodogsquared-guest;
      };

      # Some niceties.
      suites.desktop.enable = true;

      services.xserver.displayManager = {
        gdm = {
          enable = true;
          autoSuspend = false;
        };
        autoLogin = {
          enable = true;
          user = "nixos";
        };
      };
    })
  ];
}
