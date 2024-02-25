# All of the extra module arguments to be passed as part of the home-manager
# environment.
{ options, pkgs, lib, ... }:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib =
    foodogsquaredLib.extend (final: prev:
      import ../../../lib/home-manager.nix { inherit pkgs; lib = prev; }
      // lib.optionalAttrs (options?sops) {
        sops-nix = import ../../../lib/sops.nix { inherit pkgs; lib = prev; };
      });
}
