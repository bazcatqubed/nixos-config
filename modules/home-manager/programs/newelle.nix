# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  options,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.newelle;
in
{
  options.programs.newelle = {
    enable = lib.mkEnableOption "Newelle, a graphical client for chat bots";

    package = lib.mkPackageOption pkgs "newelle" { };

    settings = lib.mkOption {
      description = ''
        dconf settings specifically set for Newelle.
      '';
      type = options.dconf.settings.type;
      default = { };
      example = lib.literalExpression ''
        {
          virtualization = true;
          display-latex = true;
          websearch-on = true;
          websearch-model = "ddgsearch";
        }
      '';
    };

    extensions = lib.mkOption {
      description = ''
        List of packages containing Newelle extensions at
        `$out/share/Newelle/extensions`.
      '';
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          newelleExtensions.imageGenerator
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton cfg.package;
    dconf.settings."/io/github/qwersyk/Newelle" = lib.mkIf (cfg.settings != { }) cfg.settings;

    xdg.configFile."Newelle/extensions" = lib.mkIf (cfg.extensions != [ ]) {
      source = pkgs.symlinkJoin {
        name = "newelle-extensions";
        paths = lib.concatMap (p: [ "${p}/share/Newelle/extensions" ]) cfg.extensions;
      };
      recursive = true;
    };
  };
}
