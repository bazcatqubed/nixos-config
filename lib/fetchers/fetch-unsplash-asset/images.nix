{ lib, callPackage, stdenv, cacert }:

let
  fetcherPkg = callPackage ../../../apps/fds-fetcher-flock/nix/package.nix { };
in
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "ids"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      ids ? [ ],

      # The hash of the fixed-output derivation.
      hash,
    }@args:
    {
      name = args.name or "fetch-unsplash-images";
      nativeBuildInputs = args.nativeBuildInputs or [] ++ [ cacert ];
      buildInputs = args.buildInputs or [] ++ [ fetcherPkg ];

      buildCommand = ''
        ffof unsplash by-id ${lib.escapeShellArgs ids}
        mkdir -p $out && mv unsplash-* $out
      '';

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "FOODOGSQUARED_FFOF_UNSPLASH_API_KEY"
      ];

      outputHashMode = "recursive";
      outputHash = args.hash;
      outputHashAlgo = if args.hash == "" then "sha256" else null;
    };
}
