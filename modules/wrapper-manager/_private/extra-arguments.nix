# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  pkgs,
  lib,
  ...
}:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib = foodogsquaredLib.extend (
    final: prev:
    {
      wrapper-manager = import ../../../lib/env-specific/wrapper-manager.nix {
        inherit pkgs lib;
        self = final;
      };
    }
    // {
      extra = config.foodogsquared.lib.extra;
    }
  );
}
