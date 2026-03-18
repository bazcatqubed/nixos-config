# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
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
    plugins.telescope.enable = true;

    plugins.which-key.settings.spec = lib.optionals config.plugins.telescope.enable [
      (lib.nixvim.listToUnkeyedAttrs [ bindingPrefix ] // { group = "Telescope"; })
    ];

    # Configure all of the keymaps.
    keymaps =
      let
        mkTelescopeKeymap =
          binding: settings:
          lib.mergeAttrs {
            mode = "n";
            key = "${bindingPrefix}${binding}";
          } settings;
      in
      lib.mapAttrsToList mkTelescopeKeymap (
        {
          "A" = {
            options.desc = "Resume from last use";
            action = lib.nixvim.mkRaw "require('telescope.builtin').resume";
          };
          "b" = {
            options.desc = "List buffers";
            action = lib.nixvim.mkRaw "require('telescope.builtin').buffers";
          };
          "B" = {
            options.desc = "Grep through opened files";
            action = lib.nixvim.mkRaw ''
              function()
                require('telescope.builtin').live_grep {
                  grep_open_files = true,
                }
              end
            '';
          };
          "f" = {
            options.desc = "Find files";
            action = lib.nixvim.mkRaw ''
              function()
                require('telescope.builtin').find_files { hidden = true }
              end
            '';
          };
          "F" = {
            options.desc = "Find files in current directory";
            action = lib.nixvim.mkRaw ''
              function()
                require('telescope.builtin').find_files {
                  cwd = require('telescope.utils').buffer_dir(),
                  hidden = true,
                }
              end
            '';
          };
          "v" = {
            options.desc = "Find files tracked by Git";
            action = lib.nixvim.mkRaw "require('telescope.builtin').git_files";
          };
          "g" = {
            options.desc = "Grep for the whole project";
            action = lib.nixvim.mkRaw "require('telescope.builtin').live_grep";
          };
          "G" = {
            options.desc = "Grep through the current directory";
            action = lib.nixvim.mkRaw ''
              function()
                require('telescope.builtin').live_grep {
                  cwd = require('telescope.utils').buffer_dir(),
                }
              end
            '';
          };
          "h" = {
            options.desc = "Find section from help tags";
            action = lib.nixvim.mkRaw "require('telescope.builtin').help_tags";
          };
          "m" = {
            options.desc = "Find manpage entries";
            action = lib.nixvim.mkRaw "require('telescope.builtin').man_pages";
          };
        }
        // lib.optionalAttrs nixvimCfg.setups.treesitter.enable {
          "t" = {
            options.desc = "List symbols from treesitter queries";
            action = lib.nixvim.mkRaw "require('telescope.builtin').treesitter";
          };
        }
        // lib.optionalAttrs nixvimCfg.setups.lsp.enable {
          "d" = {
            options.desc = "List LSP definitions";
            action = lib.nixvim.mkRaw "require('telescope.builtin').lsp_definitions";
          };
        }
      );
  };
}
