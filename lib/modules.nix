# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: LGPL-2.1-or-later

{
  pkgs,
  lib,
  self,
}:

{
  /**
    Like `lib.mkEnableOption` but with the default being disabled instead.

    # Arguments
    Same as `lib.mkEnableOption`.

    # Example

    ```nix
    { lib, foodogsquaredLib, ... }:

    {
      options.x = {
        enable = foodogsquaredLib.mkEnableOption' "configuration of X server";
      };
    }
    ```
  */
  mkEnableOption' =
    desc:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Enable ${desc}";
    };
}
