{ pkgs }:

let
  inherit (pkgs) lib;
in
{
  vouch-proxy.default = {
    imports = lib.singleton (lib.modules.importApply ./vouch-proxy.nix { inherit (pkgs) formats; });

    config = {
      vouch-proxy.package = lib.mkDefault pkgs.vouch-proxy;
    };
  };
}
