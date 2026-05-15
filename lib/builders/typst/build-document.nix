# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  stdenv,
  typst,
  cacert,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "name"
    "extraPackages"
    "typstPkg"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      name ? "typst-document",
      extraPackages ? p: [ ],
      typstPkg ? typst,

      # List of files with their given formats to be appended to `--format`
      # flag. Each of the format given is then made as additional build step.
      files ? {
        "main.typ".formats.pdf = { };
      },

      # The optional vendor hash. This now turns into a fixed-output
      # derivation.
      vendorHash ? null,

      ...
    }@args:
    let
      wrappedTypst = typstPkg.withPackages extraPackages;
      vendorDir = "vendor";
      outputDir = "public";
      mkCommandPerFormat =
        fn: v:
        lib.concatMapStringsSep "\n" (
          format:
          let
            extraArgs' =
              v.extraArgs or [ ]
              ++ format.extraArgs or [ ]
              ++ [
                fn
                "${outputDir}/${fn}.${format}"
              ];
          in
          "typst compile --format ${lib.escapeShellArg format} \${buildFlags[@]} ${lib.escapeShellArgs extraArgs'};"
        ) v.formats;
    in
    {
      inherit name;

      buildInputs = args.buildInputs or [ ] ++ [
        wrappedTypst
      ];

      buildFlags =
        args.buildFlags or [
          "--root"
          "."
        ];

      buildPhase =
        args.buildPhase or ''
          runHook preBuild
          mkdir -p ${outputDir}
          ${lib.concatMapAttrsStringSep "\n" mkCommandPerFormat files}
          runHook postBuild
        '';

      installPhase =
        args.installPhase or ''
          runHook preInstall
          mkdir -p "$out" && cp -r ${outputDir}/* "$out"
          runHook postInstall
        '';

      meta = {
        platforms = lib.platforms.all;
      }
      // args.meta or { };
    }
    // lib.optionalAttrs (args.vendorHash or null != null) {
      buildInputs = args.buildInputs or [ ] ++ [
        wrappedTypst
        cacert
      ];
      buildFlags =
        args.buildFlags or [
          "--root"
          "."
          "--package-cache-path"
          vendorDir
        ];
      outputHashMode = "recursive";
      outputHash = args.vendorHash;
      outputHashAlgo = if args.vendorHash == "" then "sha256" else null;
      buildPhase =
        args.buildPhase or ''
          runHook preBuild
          mkdir -p ${outputDir}
          mkdir -p "${vendorDir}" && {
            ${lib.concatMapAttrsStringSep "\n" mkCommandPerFormat files}
          }
          runHook postBuild
        '';
      installPhase =
        args.installPhase or ''
          runHook preInstall
          mkdir -p "$out" && cp -r ${outputDir}/* "$out" && cp -r "${vendorDir}" "$out"
          runHook postInstall
        '';
    };
}
