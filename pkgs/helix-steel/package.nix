# SPDX-FileCopyrightText: 2026 Gabriel Arazas <__personal__@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  fetchFromGitHub,
  runCommand,
  helix-unwrapped,

  callPackage,
  steel,
  rustPlatform,
}:

helix-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "helix-steel-plugin-fork";
    src = fetchFromGitHub {
      owner = "mattwparas";
      repo = "helix";
      rev = "ba5b022c1000a0ce28d4ce1d09acdd062a83a020";
      hash = "sha256-vJ7VgxuM/Dp7vyVlu6EXjP/ES14TALy64jgzyuYZl6g=";
    };
    buildInputs = prevAttrs.buildInputs or [ ] ++ [
      steel
    ];
    cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [ ] ++ [
      "helix-term/steel"
      "helix-term/git"
      "helix-term/unicode-lines"
    ];
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = "sha256-gxX/gXJ9cIAShQTBSZcmAcX4qahE3zoYYmKzmFHqV7E=";
    };
    patches = [ ];
    passthru.wrapper = callPackage ./wrapper.nix { };
    env = {
      HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";
      HELIX_DEFAULT_RUNTIME = runCommand "helix-default-runtime" { } ''
        cp -r --no-preserve=mode ${finalAttrs.src}/runtime $out
        rm -rf $out/grammars $out/queries
      '';
    };
    meta = prevAttrs.meta or { } // {
      description = "Helix fork with the Steel plugin system";
    };
  }
)
