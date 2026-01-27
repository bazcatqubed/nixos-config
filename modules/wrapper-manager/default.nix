# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  imports = [
    ./programs/blender.nix
    ./programs/zellij.nix
    ./programs/neovim.nix
    ./programs/jujutsu.nix
    ./subenvironments.nix
    ./dconf.nix
    ./wraparound
  ];
}
