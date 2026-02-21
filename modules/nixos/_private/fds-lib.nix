# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ lib, ... }:

{
  options.foodogsquared.lib.extra = lib.mkOption {
    type = with lib.types; attrsOf anything;
    description = ''
      Set of attribute items to be placed under `foodogsquaredLib.extra`
      namespace.
    '';
    default = { };
    example = lib.literalExpression ''
      {
        numBits = 943;

        mkCommonChromiumFlags = name: [
          "--data-dir"
          "''${config.xdg.configHome}/chromium-''${name}"
        ];
      }
    '';
  };
}
