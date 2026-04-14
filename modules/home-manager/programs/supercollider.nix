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
  cfg = config.programs.supercollider;

  finalPkg = cfg.package.override {
    plugins = cfg.plugins;
  };
in
{
  options.programs.supercollider = {
    enable = lib.mkEnableOption "configuring SuperCollider development environment";

    package = lib.mkPackageOption pkgs "supercollider-with-plugins" { };

    plugins = lib.mkOption {
      description = ''
        List of SuperCollider plugins to be added to the wrapper.
      '';
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression ''
        with pkgs.supercolliderPlugins; [
          sc3-plugins
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton finalPkg;
  };
}
