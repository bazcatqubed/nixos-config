# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# A set of functions to facilitate testing in the project.
{ pkgs }:

let
  nixpkgsPath = pkgs.path;
  nixosLib = import "${nixpkgsPath}/nixos/lib" { };
in
rec {
  # We're not using this to test the hosts configuration (that would be
  # atrocious). We're only using this for NixOS modules.
  nixosTest =
    test:
    nixosLib.runTest {
      imports = [ test ];
      hostPkgs = pkgs;
      specialArgs = {
        foodogsquaredUtils = import ../lib/utils/nixos.nix { inherit pkgs; };
        foodogsquaredModulesPath = builtins.toString ../modules/nixos;
      };
    };
}
