# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:
{
  hosts.bootstrap.variant = lib.mkForce null;

  isoImage = {
    isoBaseName = lib.mkForce "${config.networking.hostName}-${config.isoImage.edition}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
    edition = "minimal";

    squashfsCompression = "zstd -Xcompression-level 11";

    makeEfiBootable = true;
    makeUsbBootable = true;
  };
}
