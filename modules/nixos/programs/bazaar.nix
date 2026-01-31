# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.bazaar;

  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "bazaar-settings" cfg.settings;

  finalPkg = cfg.package.overrideAttrs (final: prev: {
    mesonFlags = prev.mesonFlags or [ ] ++ (lib.optionals (cfg.settings != { }) [
      (lib.mesonOption "hardcoded_main_config_path" settingsFile)
    ]);
  });
in
{
  options.programs.bazaar = {
    enable = lib.mkEnableOption "Bazaar, a Flatpak store";

    package = lib.mkPackageOption pkgs "bazaar" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        Set the blocklist to be used by Bazaar.
      '';
      default = { };
      example = {
        blocklists = [
          {
            priority = 0;
            block-regex = [ "com\.place\..*" ];
          }

          {
            priority = -1;
            conditions = [
              { match-locale = "ar"; }
            ];
            allow = [
              "com.place.App3"
              "com.place.App5"
            ];
            allow-regex = [ "com\.place\..*\.ar" ];
          }
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ finalPkg ];
  };
}
