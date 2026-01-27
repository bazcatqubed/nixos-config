# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:

{
  imports = [ ./modules ];

  config = {
    nixvimConfigs.trovebelt.setups = {
      debugging.enable = true;
      lsp.enable = true;
      treesitter.enable = true;
      ui.enable = true;
    };

    # Some general settings.
    globals = {
      mapleader = " ";
      maplocalleader = ",";
      syntax = true;
    };

    opts = {
      encoding = "utf-8";
      completeopt = [
        "menuone"
        "noselect"
      ];
      expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
    };
  };
}
