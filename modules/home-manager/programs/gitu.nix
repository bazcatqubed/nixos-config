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
  cfg = config.programs.gitu;

  settingsFormat = pkgs.formats.toml { };
in
{
  options.programs.gitu = {
    enable = lib.mkEnableOption "configuring Gitu, a Git client";

    package = lib.mkPackageOption pkgs "gitu" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Settings to be placed in {file}`$XDG_CONFIG_HOME/gitu/config.toml`.
      '';
      example = lib.literalExpression ''
        {
          general = {
            confirm_quit.enabled = true;
            confirm_discard = "hunk";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton cfg.package;

    xdg.configFile."gitu/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = settingsFormat.generate "hm-${config.home.username}-gitu-config" cfg.settings;
    };
  };
}
