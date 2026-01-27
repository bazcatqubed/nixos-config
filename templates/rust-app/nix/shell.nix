# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { },
}:

let
  app = pkgs.callPackage ./package.nix { };
in
pkgs.mkShell {
  inputsFrom = [ app ];

  # The rest of the development-related packages should be here.
  packages = with pkgs; [
    direnv
    clippy
    rust-analyzer

    # The formatters used in this project.
    treefmt # The universal formatter (if configured nicely).
    nixfmt # The universal Nix formatter.
    rustfmt # The universal Rust formatter.
  ];
}
