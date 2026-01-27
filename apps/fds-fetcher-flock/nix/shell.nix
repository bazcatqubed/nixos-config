# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

let
  ffof = callPackage ./package.nix { };
in
mkShell {
  inputsFrom = [ ffof ];

  packages = [
    gopls
    delve
  ];
}
