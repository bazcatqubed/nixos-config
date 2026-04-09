# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.treesitter;
in
{
  options.nixvimConfigs.fiesta.setups.treesitter.enable =
    lib.mkEnableOption "tree-sitter setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable {
    extraPlugins = with pkgs.vimPlugins; [
      treewalker-nvim
    ];

    # The main star of the show.
    plugins.treesitter = {
      enable = true;

      # Install all of the grammars with Nix. We can easily replace it if we
      # want to.
      nixGrammars = true;
      nixvimInjections = true;

      # Enable all of its useful features.
      folding.enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        incremental_selection.enable = true;
      };
    };

    keymaps = lib.optionals (lib.elem pkgs.vimPlugins.treewalker-nvim config.extraPlugins) [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<C-j>";
        options = {
          desc = "Move down to closest neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker Down<CR>";
      }

      {
        mode = [
          "n"
          "v"
        ];
        key = "<C-k>";
        options = {
          desc = "Move up to neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker Up<CR>";
      }

      {
        mode = [
          "n"
          "v"
        ];
        key = "<C-h>";
        options = {
          desc = "Move to inner neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker Left<CR>";
      }

      {
        mode = [
          "n"
          "v"
        ];
        key = "<C-l>";
        options = {
          desc = "Move to outer neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker Right<CR>";
      }

      {
        mode = [
          "n"
          "v"
        ];
        key = "<A-S-j>";
        options = {
          desc = "Swap down with closest neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker SwapDown<CR>";
      }

      {
        key = "<A-S-k>";
        options = {
          desc = "Swap up with neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker SwapUp<CR>";
      }

      {
        mode = [
          "n"
          "v"
        ];
        key = "<A-S-h>";
        options = {
          desc = "Swap with inner neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker SwapLeft<CR>";
      }

      {
        mode = [
          "n"
          "v"
        ];
        key = "<A-S-l>";
        options = {
          desc = "Swap with outer neighbor node";
          silent = true;
        };
        action = "<cmd>Treewalker SwapRight<CR>";
      }
    ];

    opts = {
      foldenable = config.plugins.treesitter.folding.enable;
      foldlevelstart = 3;
      foldlevel = 5;
    };

    # Bring some convenience to editing them.
    plugins.ts-autotag.enable = true;

    # Show me your moves.
    plugins.treesitter-textobjects = {
      enable = true;
      settings.lsp_interop = {
        enable = true;
        border = "none";
        peek_definition_code =
          let
            bindingPrefix = "<leader>d";

            mkQueryMappings =
              query: binding:
              lib.nameValuePair "${bindingPrefix}${binding}" {
                desc = "Peek definition of ${query}";
                query = "@${query}.outer";
              };
          in
          lib.mapAttrs' mkQueryMappings {
            "function" = "f";
            "class" = "F";
          };
      };

      settings.select = {
        enable = true;
        lookahead = true;
        selection_modes = {
          "@function.outer" = "V";
          "@class.outer" = "<c-v>";
          "@block.outer" = "<c-v>";
        };
        keymaps =
          let
            prefixMap = {
              "outer" = {
                key = "a";
                desc = query: "Select around the ${query} region";
              };
              "inner" = {
                key = "i";
                desc = query: "Select inner part of the ${query} region";
              };
            };

            # A function that creates a pair of keymaps: one for the outer and
            # inner part of the query. As such, it assumes the query has an
            # outer and inner variant.
            mkQueryMappings =
              # The textobject query, assumed as "@$QUERY.$VARIANT".
              query:

              # The keymap sequence to affix for the mapping pair.
              binding:

              let
                mappingsList =
                  lib.map
                    (
                      variant:
                      let
                        prefixMap' = prefixMap.${variant};
                      in
                      lib.nameValuePair "${prefixMap'.key}${binding}" {
                        query = "@${query}.${variant}";
                        desc = prefixMap'.desc query;
                      }
                    )
                    [
                      "outer"
                      "inner"
                    ];
              in
              lib.listToAttrs mappingsList;
          in
          lib.concatMapAttrs mkQueryMappings {
            "function" = "m";
            "call" = "f";
            "class" = "c";
            "block" = "b";
            "loop" = "l";
            "statement" = "s";
            "attribute" = "a";
          };
      };
    };
  };
}
