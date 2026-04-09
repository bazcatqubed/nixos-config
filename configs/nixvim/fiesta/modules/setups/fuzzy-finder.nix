# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  foodogsquaredLib,
  ...
}:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.fuzzy-finder;
  bindingPrefix = "<leader>f";
in
{
  options.nixvimConfigs.fiesta.setups.fuzzy-finder.enable = lib.mkEnableOption "fuzzy finder setup";

  config = lib.mkIf cfg.enable {
    assertions = lib.singleton {
      assertion = config.plugins.snacks.enable;
      message = ''
        snacks.nvim is not enabled (e.g., `config.plugins.snacks.enable =
        false`). This is configured with its picker submodule.
      '';
    };

    plugins.snacks.settings.picker.enabled = true;

    plugins.which-key.settings.spec = lib.optionals (config.plugins.snacks.settings.picker.enabled) [
      (lib.nixvim.listToUnkeyedAttrs [ bindingPrefix ] // { group = "Pickers"; })
    ];

    # Configure all of the keymaps.
    keymaps =
      foodogsquaredLib.nixvim.mkPrefixBinding { prefix = bindingPrefix; } (
        {
          "A" = {
            options.desc = "Resume last picker";
            action = lib.nixvim.mkRaw "require('snacks').picker.resume";
          };
          "b" = {
            options.desc = "Buffers";
            action = lib.nixvim.mkRaw "require('snacks').picker.buffers";
          };
          "B" = {
            options.desc = "Grep through opened buffers";
            action = lib.nixvim.mkRaw "require('snacks').picker.grep_buffers";
          };
          "f" = {
            options.desc = "Find files";
            action = lib.nixvim.mkRaw ''
              require('snacks').picker.files
            '';
          };
          "F" = {
            options.desc = "Find files in current directory";
            action = lib.nixvim.mkRaw ''
              function()
                require('snacks').picker.files({
                  cwd = vim.fn.expand("%:p:h"),
                })
              end
            '';
          };
          "g" = {
            options.desc = "Grep for the whole project";
            action = lib.nixvim.mkRaw "require('snacks').picker.grep";
          };
          "G" = {
            options.desc = "Grep through the current directory";
            action = lib.nixvim.mkRaw ''
              function()
                require('snacks').picker.grep({
                  cwd = vim.fn.expand("%:p:h"),
                })
              end
            '';
          };
          "h" = {
            options.desc = "Help pages";
            action = lib.nixvim.mkRaw "require('snacks').picker.help";
          };
          "m" = {
            options.desc = "Manpages";
            action = lib.nixvim.mkRaw "require('snacks').picker.man";
          };
        }
        // lib.optionalAttrs nixvimCfg.setups.treesitter.enable {
          "t" = {
            options.desc = "List symbols from treesitter queries";
            action = lib.nixvim.mkRaw "require('snacks').picker.treesitter";
          };
        }
      )
      ++ lib.optionals nixvimCfg.setups.lsp.enable [
        {
          key = "<leader>s";
          mode = [ "n" ];
          options.desc = "Symbols for current file";
          action = lib.nixvim.mkRaw ''
            function()
              require("snacks").picker.lsp_symbols({
                layout = {
                  preset = "vscode",
                  preview = "main",
                },
              })
            end
          '';
        }

        {
          key = "<leader>S";
          mode = [ "n" ];
          options.desc = "Symbols for workspace";
          action = lib.nixvim.mkRaw ''
            function()
              require("snacks").picker.lsp_workspace_symbols({
                layout = {
                  preset = "vscode",
                },
                tree = true,
              })
            end
          '';
        }
      ];
  };
}
