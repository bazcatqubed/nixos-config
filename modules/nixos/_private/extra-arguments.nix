# All of the extra module arguments to be passed as part of the holistic NixOS
# system.
{ options, lib, ... }:

let
  foodogsquaredLib = import ../../../lib { inherit lib; };
in
{
  _module.args.foodogsquaredLib =
    foodogsquaredLib.extend (self:
      import ../../../lib/nixos.nix { inherit lib; }
      // lib.optionalAttrs (options?sops) {
        sops-nix = import ../../../lib/sops.nix { inherit lib; };
      });
}
