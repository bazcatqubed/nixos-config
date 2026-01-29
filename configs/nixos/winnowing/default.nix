# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  modulesPath,
  foodogsquaredLib,
  foodogsquaredUtils,
  ...
}:

{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    (foodogsquaredUtils.mapHomeManagerUser "winnow" {
      extraGroups = [
        "wheel"
        "docker"
        "podman"
      ];
      hashedPassword = "$y$j9T$UFzEKZZZrmbJ05CTY8QAW0$X2RD4m.xswyJlXZC6AlmmuubPaWPQZg/Q1LDgHpXHx1";
      isNormalUser = true;
      createHome = true;
      home = "/home/winnow";
      description = "Some type of bird";
    })
  ];

  wsl = {
    enable = true;
    defaultUser = "winnow";
  };

  programs.bash.loginShellInit = "nixos-wsl-welcome";

  programs.git.package = lib.mkForce pkgs.git;

  # Setting the development environment mainly for container-related work.
  suites.dev.enable = true;
  suites.dev.containers.enable = true;
}
