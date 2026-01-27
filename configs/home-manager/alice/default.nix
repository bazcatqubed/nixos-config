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
  suites = {
    dev = {
      enable = true;
      shell.enable = true;
    };
    editors.neovim.enable = true;
  };

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };

  # My user shell of choice because I'm not a hipster.
  programs.bash = {
    enable = true;
    historyControl = [
      "erasedups"
      "ignoredups"
      "ignorespace"
    ];
    historyIgnore = [
      "cd"
      "exit"
      "lf"
      "ls"
      "nvim"
    ];
  };

  home.stateVersion = "23.11";
}
