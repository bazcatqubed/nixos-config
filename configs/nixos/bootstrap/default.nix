# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  modulesPath,
  foodogsquaredUtils,
  foodogsquaredModulesPath,
  ...
}:

# Since this will be exported as an installer ISO, you'll have to keep in mind
# about the added imports from nixos-generators. In this case, it simply adds
# the NixOS installation CD profile.
#
# This means, there will be a "nixos" user among other things.
{
  imports = [
    ./disko.nix
    ./modules

    "${foodogsquaredModulesPath}/profiles/installer.nix"
    (foodogsquaredUtils.mapHomeManagerUser "nixos" { })
  ];

  config = {
    hosts.bootstrap.variant = "graphical";

    boot.kernelPackages = pkgs.linuxPackages_6_12;
    boot.loader.systemd-boot = {
      enable = true;
      netbootxyz.enable = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    # Assume that this will be used for remote installations.
    services.openssh = {
      enable = true;
      allowSFTP = true;
    };

    system.stateVersion = "23.11";

    image.modules = {
      fds-install-iso.imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
        ./modules/profiles/install-iso.nix
      ];
      fds-install-iso-graphical.imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
        "${foodogsquaredModulesPath}/profiles/image/install-iso-graphical.nix"
        ./modules/profiles/install-iso-graphical.nix
      ];
    };
  };
}
