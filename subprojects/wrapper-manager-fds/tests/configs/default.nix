let
  sources = import ../../npins;
in
{ pkgs ? import sources.nixos-unstable { } }:

let
  wmLib = (import ../../. { }).lib;
  build = modules: wmLib.build {
    inherit pkgs modules;
  };
in
{
  fastfetch = build [ ./wrapper-fastfetch.nix ];
  neofetch = build [ ./wrapper-neofetch.nix ];
}
