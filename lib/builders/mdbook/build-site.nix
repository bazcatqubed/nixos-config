{ lib, stdenv, mdbook, rustPlatform }:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "buildDir"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      buildDir ? "book",

      ...
    }@args:
    {
      nativeBuildInputs = args.nativeBuildInputs or [ ] ++ [
        rustPlatform.cargo
        rustPlatform.rustc
      ];

      buildInputs = args.buildInputs or [ ] ++ [ mdbook ];
      buildFlags = args.buildFlags or [ ] ++ [ "--dest-dir" buildDir ];

      buildPhase = args.buildPhase or ''
        runHook preBuild

        mdbook ''${buildFlags[@]}

        runHook postBuild
      '';

      installPhase = args.installPhase or ''
        runHook preInstall

        cp -r ./${buildDir}/* $out/

        runHook postInstall
      '';

      doCheck = args.doCheck or true;
      dontFixup = args.dontFixup or true;

      passthru = args.passthru or { } // {
        inherit rustPlatform;
        inherit mdbook;
      };
    };
}
