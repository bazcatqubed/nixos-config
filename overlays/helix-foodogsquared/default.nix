# SPDX-FileCopyrightText: 2026 Gabriel Arazas <__personal__@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

final: prev:

prev.lib.recurseIntoAttrs {
  helix-steel-plugin-unwrapped = prev.helix-unwrapped.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "helix-steel-plugin-fork";
      src = prev.fetchFromGitHub {
        owner = "mattwparas";
        repo = "helix";
        rev = "ba5b022c1000a0ce28d4ce1d09acdd062a83a020";
        hash = "sha256-vJ7VgxuM/Dp7vyVlu6EXjP/ES14TALy64jgzyuYZl6g=";
      };
      buildInputs = prevAttrs.buildInputs or [ ] ++ [
        prev.steel
      ];
      cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [ ] ++ [
        "helix-term/steel"
        "helix-term/git"
        "helix-term/unicode-lines"
      ];
      cargoDeps = prev.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        hash = "sha256-gxX/gXJ9cIAShQTBSZcmAcX4qahE3zoYYmKzmFHqV7E=";
      };
      patches = [ ];
      meta = prevAttrs.meta or { } // {
        description = "Helix fork with the Steel plugin system";
      };
    }
  );

  helix-steel-plugin = prev.helix.override {
    helix-unwrapped = final.helix-steel-plugin-unwrapped;
  };
}
