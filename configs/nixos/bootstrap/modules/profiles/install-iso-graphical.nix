# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  config,
  pkgs,

  ...
}:

{
  isoImage = {
    isoBaseName = lib.mkForce "${config.networking.hostName}-${config.isoImage.edition}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
    edition = "a-happy-gnome";

    squashfsCompression = "zstd -Xcompression-level 12";
  };
}
