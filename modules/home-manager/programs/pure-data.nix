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
  cfg = config.programs.pure-data;

  wrapper = pkgs.callPackage "${pkgs.path}/pkgs/by-name/pu/puredata/wrapper.nix" {
    inherit (cfg) plugins;
    puredata = cfg.package;
  };
in
{
  options.programs.pure-data = {
    enable = lib.mkEnableOption "Pure Data environment";

    package = lib.mkPackageOption pkgs "puredata" { };

    plugins = lib.mkOption {
      description = ''
        List of plugins to be included within the Pure Data environment.
      '';
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          zexy
          cyclone
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton wrapper;
  };
}
