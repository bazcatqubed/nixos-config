# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# A dedicated profile for installers with some niceties in it. This is also
# used for persistent live installers so you'll have to exclude setting up shop
# and do that in the respective NixOS configuration instead.
{
  pkgs,
  lib,
  modulesPath,
  foodogsquaredLib,
  ...
}:

{
  imports = [
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/installation-device.nix"
  ];

  # Include some modern niceties.
  environment.systemPackages =
    with pkgs;
    [
      curl
      disko
      ripgrep
      git
      lazygit
      neovim
      zellij
    ]
    ++ foodogsquaredLib.stdenv;

  # Yeah, that's right, this is also a Guix System installer because SCREW YOU,
  # NIXOS USERS!
  services.guix.enable = lib.mkDefault true;

  # We're putting our custom plugins here since we're using it to install our
  # private configurations which contains code using the plugins anyways.
  nix.settings.plugin-files = lib.singleton "${foodogsquaredLib.nixPlugins}/lib/nix/plugins/foodogsquared";
}
