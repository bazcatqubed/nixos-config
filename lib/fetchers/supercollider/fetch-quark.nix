# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  stdenv,
  supercollider,
  cacert,
  which,
  gitMinimal,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "lockfile"
    "urls"
    "hash"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      lockfile ? null,
      hash ? null,
      urls ? [ ],
      ...
    }@args:
    {
      name =
        args.name or (
          if (lib.length urls) == 1 then
            "supercollider-quark-${lib.head urls}"
          else
            "supercollider-quarks-multi-${lib.head urls}"
        );
      nativeBuildInputs = args.nativeBuildInputs or [ ] ++ [ cacert ];
      buildInputs = args.buildInputs or [ ] ++ [
        which
        gitMinimal
        supercollider
      ];

      env = {
        QT_QPA_PLATFORM = "minimal";
      };

      quarkInit = /* supercollider */ ''
        Quarks.gui;
        Quarks.clear;
        ${lib.optionalString (urls != [ ]) (lib.concatMapStrings (q: "Quarks.install(\"${q}\");\n") urls)}
        ${lib.optionalString (lockfile != null) "Quarks.load(\"${lockfile}\");\n"}
        File.use("sc-quirks-path", "w", { |f| f.write(Quarks.folder) });
        0.exit;
      '';

      buildCommand = /* bash */ ''
        HOME=$(pwd) sclang "$quarkInitPath"

        SC_EXTENSIONS_DIR="$out/share/SuperCollider/Extensions"
        SC_QUARKS_DIR=$(cat sc-quirks-path)
        rm -rf $SC_QUARKS_DIR/**/.git
        rm -rf $SC_QUARKS_DIR/quarks
        mkdir -p "$SC_EXTENSIONS_DIR" && mv $SC_QUARKS_DIR/* "$SC_EXTENSIONS_DIR"
      '';

      impureEnvVars = lib.fetchers.proxyImpureEnvVars;

      passAsFile = [ "quarkInit" ];

      outputHashMode = "recursive";
      outputHash = args.hash;
      outputHashAlgo = if args.hash == "" then "sha256" else null;
    };
}
