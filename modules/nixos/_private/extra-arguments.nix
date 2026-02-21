# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# All of the extra module arguments to be passed as part of the holistic NixOS
# system.
{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  foodogsquaredLib = import ../../../lib { inherit pkgs; };
in
{
  _module.args.foodogsquaredLib = foodogsquaredLib.extend (
    final: prev:
    {
      nixos = import ../../../lib/env-specific/nixos.nix {
        inherit pkgs lib;
        self = final;
      };
    }
    // lib.optionalAttrs (options ? sops) {
      sops-nix = import ../../../lib/env-specific/sops.nix {
        inherit pkgs lib;
        self = final;
      };
    }
    // lib.optionalAttrs (options ? wrapper-manager) {
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
