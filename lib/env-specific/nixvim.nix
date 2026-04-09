# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  lib,
  self,
}:

rec {
  isStandalone = config: !config ? hmConfig && !config ? nixosConfig && !config ? darwinConfig;

  mkPrefixBindingFunc =
    { prefix, ... }@attrs:
    binding: settings:
    lib.mergeAttrs {
      mode = attrs.mode or "n";
      key = "${prefix}${binding}";
    } settings;

  mkPrefixBinding = attrs: lib.mapAttrsToList (mkPrefixBindingFunc attrs);
}
