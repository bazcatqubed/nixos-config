# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  stdenv,
  supercollider,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "quarks"
    "quarkSettings"
    "supercolliderPkg"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      name ? "supercollider-quarks",

      quarks ? [ ],
      supercolliderPkg ? supercollider,

      quarkSettings ?
        if quarks != [ ] then
          {
            includePaths = [ "$out/share/SuperCollider/Extensions" ];
          }
        else
          null,

      ...
    }@args:
    {
      inherit name;

      quarkSettings = lib.generators.toYAML { } quarkSettings;

      quarkInstall = /* scd */ ''
        Quarks.clear;
        Quarks.install(${placeholder "out"});
        thisProcess.recompile();
      '';

      passAsFile = [
        "quarkSettings"
        "quarkInstall"
      ];

      installPhase = ''
        runHook preInstall

        EXTENSION_DIR=$out/share/SuperCollider/Extensions
        mkdir -p "$EXTENSION_DIR" && cp --recursive ./* "$EXTENSION_DIR"

        runHook postInstall
      '';

      passthru = args.passthru or { } // {
        supercolliderQuark = {
          supercollider = supercolliderPkg;
        };
      };
    };
}
