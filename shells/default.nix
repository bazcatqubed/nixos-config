{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  flatpak = callPackage ./flatpak.nix { };
  hugo = callPackage ./hugo.nix { };
  rust = callPackage ./rust.nix { };
}
