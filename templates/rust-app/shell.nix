# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ pkgs }:

let
  app = pkgs.callPackage ./. { };
in
pkgs.mkShell {
  inputsFrom = [ app ];

  packages = with pkgs; [
    treefmt
    rust-analyzer
  ];
}
