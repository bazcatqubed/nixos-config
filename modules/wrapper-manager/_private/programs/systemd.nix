# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

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
