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
  cfg = config.programs.haskell;

  finalPkg = cfg.package.withPackages cfg.libraries;
in
{
  options.programs.haskell = {
    enable = lib.mkEnableOption "configuring Haskell and its libraries";

    package = lib.mkPackageOption pkgs [ "haskell" "packages" "ghc98" "ghc" ] { };

    libraries = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      default = _: [ ];
      example = lib.literalExpression ''
        ghcPackages: with ghcPackages; [
          cabal-install
          arrows
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton finalPkg;
  };
}
