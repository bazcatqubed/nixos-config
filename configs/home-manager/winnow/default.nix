# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    vimAlias = true;
    vimdiffAlias = true;

    withRuby = true;
    withNodeJs = true;
    withPython3 = true;
  };

  systemd.user.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };
}
