# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  stdenv,
  formats,
  marp-cli,
  chromium,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "name"
    "formats"
    "browser"
    "settings"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      name ? "marp-slides",

      formats ? [ ],

      browser ? chromium,

      settings ? { },

      ...
    }@args:
    let
      settingsFormat = formats.yaml { };
    in
    {
      inherit name;
      buildInputs = args.buildInputs or [ ] ++ [
        marp-cli
      ];

      buildFlags =
        args.buildFlags or [ ]
        ++ [
          "--input-dir"
          "./"
          "--output"
          "public"
          "--allow-local-files"
        ]
        ++ lib.optionals (browser != null) [
          "--browser-path"
          (lib.getExe browser)
        ]
        ++ lib.optionals (settings != { }) [
          "--config-file"
          (settingsFormat.generate "marp-config-${name}" settings)
        ];

      buildPhase =
        args.buildPhase or ''
          runHook preBuild

          (
            export HOME=$(pwd)
            ${lib.optionalString (formats == [ ]) ''
              marp ''${buildFlags[@]}
            ''}
            ${lib.concatMapStringsSep "\n" (
              f: "marp \${buildFlags[@]} ${lib.escapeShellArg "--${f}"}"
            ) formats}
          )

          runHook postBuild
        '';

      installPhase =
        args.installPhase or ''
          runHook preInstall

          mkdir -p "$out" && cp -r ./public/* "$out"

          runHook postInstall
        '';

      passthru = args.passthru or { } // {
        marp = {
          inherit browser settings;
        };
      };

      meta = {
        platforms = lib.platforms.all;
      }
      // args.meta or { };
    };
}
