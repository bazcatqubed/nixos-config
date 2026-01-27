# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# A module for specifically setting the nixpkgs instance with our own overlays.
{ lib, ... }:

{
  nixpkgs.overlays = lib.attrValues (import ../../../overlays);
}
