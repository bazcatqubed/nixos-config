# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:

{
  options.specialArgs = lib.mkOption {
    type = with lib.types; attrsOf anything;
    default = { };
    example = lib.literalExpression ''
      {
        location = "Your mom's home";
        utilsLib = import ./lib/utils.nix;
      }
    '';
  };
}
