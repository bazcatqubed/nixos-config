# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { },
}:

let
  app = pkgs.callPackage ./. { };
in
pkgs.mkShell {
  inputsFrom = [ app ];

  packages = with pkgs; [
    git
    clang-tools
  ];
}
