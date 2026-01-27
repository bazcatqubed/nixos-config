# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  bahaghariLib,
}@args:

let
  callLib = path: import path args;
in
{
  tinted-theming = callLib ./tinted-theming.nix;
}
