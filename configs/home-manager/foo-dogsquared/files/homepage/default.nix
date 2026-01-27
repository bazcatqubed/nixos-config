# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { overlays = [ (import ../../../../../overlays).default ]; },
}:

pkgs.callPackage ./package.nix { }
