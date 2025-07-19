{ config, lib, pkgs, helpers, ... }:

{
  imports = [ ./modules ];

  config = {
    nixvimConfigs.fiesta.setups = {
      buffers.enable = true;
      devenvs.enable = true;
      snippets.enable = true;
      ui.enable = true;
      completion.enable = true;
      treesitter.enable = true;
      lsp.enable = true;
      fuzzy-finder.enable = true;
      debugging.enable = true;
      desktop-utils.enable = true;
      qol.enable = true;
    };

    # Some general settings.
    globals = {
      mapleader = " ";
      maplocalleader = ",";
      syntax = true;
    };

    opts = {
      encoding = "utf-8";
      completeopt = [ "menuone" "noselect" ];
      expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
    };

    keymaps = [
      {
        mode = [ "i" "v" ];
        key = "jk";
        action = "<Esc>";
        options.desc = "Escape";
      }
    ];
  };
}
