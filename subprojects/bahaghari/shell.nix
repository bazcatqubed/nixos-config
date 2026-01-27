# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

let
  sources = import ./npins;
in
{
  pkgs ? import sources.nixos-stable { },
}:

with pkgs;

mkShell {
  inputsFrom = [ nix ];

  packages = [
    npins
    nixdoc

    treefmt
    nixfmt-rfc-style
  ];
}
