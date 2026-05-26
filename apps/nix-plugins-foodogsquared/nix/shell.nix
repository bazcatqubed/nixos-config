# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: LGPL-2.1-or-later

{
  pkgs ? import <nixpkgs> { },
}:

let
  mainPkg = pkgs.callPackage ./package.nix { };
in
pkgs.mkShell {
  inputsFrom = [ mainPkg ];

  packages = with pkgs; [
    treefmt
    nixfmt
  ];
}
