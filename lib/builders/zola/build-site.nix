# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  stdenv,
  zola,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "buildDir"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      buildDir ? "public",
      ...
    }@args:
    {
      buildInputs = args.buildInputs or [ ] ++ [ zola ];
      buildFlags = args.buildFlags or [ ] ++ [
        "--output-dir"
        buildDir
      ];
      buildPhase =
        args.buildPhase or ''
          runHook preBuild
          zola build ''${buildFlags[@]}
          runHook postBuild
        '';

      doCheck = args.doCheck or true;
      checkFlags = args.checkFlags or [ "--skip-external-links" ];
      checkPhase =
        args.checkPhase or ''
          runHook preCheck
          zola check ''${checkFlags[@]}
          runHook postCheck
        '';

      installPhase =
        args.installPhase or ''
          runHook preInstall
          mkdir -p $out/ && cp -r ./${buildDir}/* $out/
          runHook postInstall
        '';

      dontFixup = args.dontFixup or true;
    };
}
