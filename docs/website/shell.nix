# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { overlays = [ (import ../../overlays).default ]; },
}:

let
  site = pkgs.callPackage ./package.nix { };
in
pkgs.mkShell {
  inputsFrom = [ site ];

  packages = with pkgs; [
    bundix

    nodePackages.prettier
    vscode-langservers-extracted
  ];
}
