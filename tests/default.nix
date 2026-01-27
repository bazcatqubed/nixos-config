# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

let
  flakeUtils = import ../lib/flake.nix;
  flake = flakeUtils.importFlakeMetadata ../flake.lock;
in
{
  pkgs ? import (flakeUtils.fetchTree flake "nixos-unstable") { },
}:

let
  utils = import ./utils.nix { inherit pkgs; };
in
{
  lib = import ./lib { inherit pkgs utils; };
  modules = {
    home-manager = import ./modules/home-manager { inherit pkgs utils; };
    nixos = import ./modules/nixos { inherit pkgs utils; };
    wrapper-manager = import ./modules/wrapper-manager { inherit pkgs utils; };
  };
}
