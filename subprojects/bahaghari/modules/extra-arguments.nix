# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

let
  bahaghariLib = import ../lib { inherit pkgs; };
in
{
  # Setting the Bahaghari lib and extra utilities. The extra utilities are
  # largely based from the `utils` module argument found in NixOS systems.
  _module.args = {
    inherit bahaghariLib;
    bahaghariUtils = import ../utils {
      inherit
        config
        pkgs
        lib
        bahaghariLib
        ;
    };
  };
}
