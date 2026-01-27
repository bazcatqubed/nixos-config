# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ lib, foodogsquaredLib, ... }:

let
  inherit (foodogsquaredLib.wrapper-manager) systemdSubenvModule;

  componentSubmodule = args: {
    options.systemd = {
      serviceUnit = lib.mkOption {
        type = lib.types.submodule systemdSubenvModule;
      };
      socketUnit = lib.mkOption {
        type = with lib.types; nullOr (submodule systemdSubenvModule);
      };
    };
  };

  sessionSubmodule = args: {
    options.components = lib.mkOption {
      type = with lib.types; attrsOf (submodule componentSubmodule);
    };
  };
in
{
  options.programs.gnome-session.sessions = lib.mkOption {
    type = with lib.types; attrsOf (submodule sessionSubmodule);
  };
}
