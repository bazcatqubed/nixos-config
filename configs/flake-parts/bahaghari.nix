# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# Bahaghari's subproject. We're primarily exporting to use Bahaghari without
# referring to its flake which is bad since the lockfile will constantly
# update. Not a good look.
{ lib, ... }:

{
  flake = {
    bahaghariLib = ../../subprojects/bahaghari/lib;
    homeModules.bahaghari = ../../subprojects/bahaghari/modules;
    nixosModules.bahaghari = ../../subprojects/bahaghari/modules;
    nixvimModules.bahaghari = ../../subprojects/bahaghari/modules;
  };
}
