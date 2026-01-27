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
  cfg = config.programs.python;
in
{
  options.programs.python = {
    enable = lib.mkEnableOption "user-wide Python installation";
    package = lib.mkPackageOption pkgs "python3" { };
    modules = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      default = [ ];
      description = ''
        A list of Python modules to be included alongside the Python
        installation.
      '';
      example = lib.literalExpression ''
        ps: with ps; [
          jupyter
        ];
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (cfg.package.withPackages cfg.modules) ];
  };
}
