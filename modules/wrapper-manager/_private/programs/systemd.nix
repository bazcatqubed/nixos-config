{ lib, foodogsquaredLib, ... }:


let
  inherit (foodogsquaredLib.wrapper-manager) systemdSubenvModule;
  mkSubenvironmentModule = lib.mkOption {
    type = with lib.types; attrsOf (submodule systemdSubenvModule);
  };
in
{
  options.programs.systemd = {
    system.services = mkSubenvironmentModule;
    system.sockets = mkSubenvironmentModule;
  };
}
