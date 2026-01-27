# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { overlays = [ (import ../overlays).default ]; },
}:

let
  inherit (pkgs) callPackage;
in
{
  creatives = callPackage ./creatives.nix { };
  typicalDevenv = callPackage ./typical-devenv.nix { };
  rustBackend = callPackage ./rust-backend.nix { };
  jsBackend = callPackage ./js-backend.nix { };
  ruby_3_3 = callPackage ./ruby-on-rails.nix { ruby = pkgs.ruby_3_3; };
  ruby_3_4 = callPackage ./ruby-on-rails.nix { ruby = pkgs.ruby_3_4; };
  ruby_3_5 = callPackage ./ruby-on-rails.nix { ruby = pkgs.ruby_3_5; };
}
