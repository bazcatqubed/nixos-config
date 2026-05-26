# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: LGPL-2.1-or-later

{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ./package.nix { lix = pkgs.lixPackageSets.lix_2_95.lix; }
