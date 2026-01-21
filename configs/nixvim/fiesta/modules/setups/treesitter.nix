{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.treesitter;

  lspSwapBindingPrefix = "<leader>s";
in
{
  options.nixvimConfigs.fiesta.setups.treesitter.enable =
    lib.mkEnableOption "tree-sitter setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable {
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

    keymaps = lib.optionals config.plugins.treesitter-context.enable [
      {
        mode = "n";
        key = "[c";
        options = {
          desc = "Go to context upwards";
          silent = true;
        };
        action = helpers.mkRaw ''
          function()
            require("treesitter-context").go_to_context(vim.v.count1)
          end
        '';
      }

      {
        mode = "n";
        key = "<leader>Lc";
        options.desc = "Toggle context";
        action = "<cmd>TSContext toggle<CR>";
      }
    ];

    opts = {
      foldenable = config.plugins.treesitter.folding.enable;
      foldlevelstart = 3;
      foldlevel = 5;
    };

    # Some niceties for refactoring.
    plugins.treesitter-refactor = {
      enable = false;
      settings = {
        highlight_current_scope.enable = false;
        highlight_definitions.enable = true;
        navigation.enable = true;
        smart_rename.enable = true;
      };
    };

    plugins.treesitter-context = {
      enable = true;

      # Enable the plugin, just don't enable it by default. ;p
      settings.enable = false;
    };

    # Bring some convenience to editing them.
    plugins.ts-autotag.enable = true;

    plugins.which-key.settings.spec =
      lib.optionals config.plugins.treesitter-textobjects.settings.swap.enable
        [
          (helpers.listToUnkeyedAttrs [ lspSwapBindingPrefix ] // { group = "Swap"; })
        ];

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

      settings.move = lib.mkMerge (
        [
          {
            enable = true;
            set_jumps = true;
          }
        ]
        ++ (
          let
            motions = lib.cartesianProduct {
              region = [
                "start"
                "end"
              ];
              jumpDirection = [
                "Previous"
                "Next"
              ];
              variant = [
                "outer"
                "inner"
              ];
            };

            motionMap = {
              outerPrevious = "[";
              outerNext = "]";
              innerPrevious = "[[";
              innerNext = "]]";
            };

            actionDesc =
              variant: jumpDirection: query:
              if variant == "inner" then
                "Jump to inner part of the ${jumpDirection} ${query}"
              else
                "Jump to ${jumpDirection} ${query}";

            mkQueryMappings =
              # The accumulator. Should be a list where it contains all of the
              # modules to be merged.
              acc:

              # The query object of the treesitter node. All queries are
              # assumed to be "@$QUERY.outer".
              query:

              # A set of bindings to be used for each jump direction.
              bindings:
              let
                mappings = lib.map (
                  motion:
                  let
                    inherit (motion) region jumpDirection variant;
                    jumpDirection' = lib.strings.toLower jumpDirection;
                    binding' = bindings.${jumpDirection'};
                    bindingPrefix = motionMap."${variant}${jumpDirection}";
                  in
                  {
                    "goto_${jumpDirection}_${region}" = {
                      "${bindingPrefix}${binding'}" = {
                        desc = actionDesc variant jumpDirection' query;
                        query = "@${query}.${variant}";
                      };
                    };
                  }
                ) motions;
              in
              acc ++ mappings;
          in
          lib.foldlAttrs mkQueryMappings [ ] {
            "function" = {
              previous = "m";
              next = "m";
            };
            "block" = {
              previous = "b";
              next = "b";
            };
            "call" = {
              previous = "f";
              next = "f";
            };
            "class" = {
              previous = "c";
              next = "c";
            };
            "conditional" = {
              previous = "D";
              next = "d";
            };
            "statement" = {
              previous = "S";
              next = "s";
            };
            "loop" = {
              previous = "L";
              next = "l";
            };
          }
        )
      );

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

      settings.swap = lib.mkMerge (
        [ { enable = true; } ]
        ++ (
          let
            motions = lib.cartesianProduct {
              jumpDirection = [
                "Previous"
                "Next"
              ];
              variant = [ "outer" ];
            };

            actionDesc =
              variant: jumpDirection: query:
              if variant == "inner" then
                "Jump to inner part of the ${jumpDirection} ${query}"
              else
                "Jump to ${jumpDirection} ${query}";

            mkQueryMappings =
              acc: query: bindings:
              let
                mappings = lib.map (
                  motion:
                  let
                    inherit (motion) jumpDirection variant;
                    jumpDirection' = lib.strings.toLower jumpDirection;
                  in
                  {
                    "swap_${jumpDirection}" = {
                      "${lspSwapBindingPrefix}${bindings.${jumpDirection'}}" = {
                        desc = actionDesc variant jumpDirection' query;
                        query = "@${query}.${variant}";
                      };
                    };
                  }
                ) motions;
              in
              acc ++ mappings;
          in
          lib.foldlAttrs mkQueryMappings [ ] {
            "function" = {
              next = "f";
              previous = "F";
            };
            "parameter" = {
              next = "a";
              previous = "A";
            };
            "conditional" = {
              next = "d";
              previous = "D";
            };
          }
        )
      );
    };
  };
}
