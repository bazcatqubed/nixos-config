# SPDX-FileCopyrightText: 2023-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { },
  extraBuildInputs ? [ ],
  extraPackages ? [ ],
}:

with pkgs;

mkShell {
  buildInputs = extraBuildInputs;

  packages = [
    # Formatters
    nixpkgs-fmt

    # Language servers
    rnix-lsp
  ]
  ++ extraPackages;
}
