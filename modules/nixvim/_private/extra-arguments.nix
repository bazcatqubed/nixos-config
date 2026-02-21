# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# All of the extra module arguments to be passed as part of NixVim module.
{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib = foodogsquaredLib.extend (
    final: prev:
    {
      nixvim = import ../../../lib/env-specific/nixvim.nix {
        inherit pkgs lib;
        self = final;
      };
    }
    // {
      extra = config.foodogsquared.lib.extra;
    }
  );
}
