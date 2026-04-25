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
  cfg = nixvimCfg.setups.devenvs;
in
{
  options.nixvimConfigs.fiesta.setups.qol.enable = lib.mkEnableOption "quality-of-life improvements";

  config = lib.mkIf cfg.enable {
    extraPackages = lib.optionals config.plugins.snacks.settings.lazygit.enabled [
      pkgs.lazygit
    ];

    plugins.mini = {
      enable = true;
      modules = {
        ai = {
          n_lines = 50;
          search_method = "cover_or_next";
        };
        surround = { };
        align = { };
        bracketed = { };
      };
    };

    plugins.snacks = {
      enable = true;
      settings = lib.mkMerge [
        {
          scope.enabled = true;
          picker.enabled = true;
          rename.enabled = true;
          lazygit.enabled = true;
        }

        (lib.mkIf config.plugins.flash.enable {
          picker.win.input.keys = {
            "<a-s>" = lib.nixvim.listToUnkeyedAttrs [ "flash" ] // {
              mode = [
                "n"
                "i"
              ];
            };
            "s" = lib.nixvim.listToUnkeyedAttrs [ "flash" ];
          };

          actions.flash = lib.nixvim.mkRaw /* lua */ ''
            function()
              require("flash").jump({
                pattern = "^",
                label = { after = { 0, 0 } },
                search = {
                  mode = "search",
                  exclude = {
                    function(win)
                      return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                    end,
                  },
                },
                action = function(match)
                  local idx = picker.list:row2idx(match.pos[1])
                  picker.list:_move(idx, true, true)
                end,
              })
            end
          '';
        })
      ];
    };

    # Move at the speed o' sound.
    plugins.flash = {
      enable = true;
      settings = {
        jump.nohlsearch = true;
        treesitter = lib.mkIf config.plugins.treesitter.enable {
          search.incremental = true;
        };

        treesitter_search = lib.mkIf config.plugins.treesitter.enable {
          search.incremental = true;
        };
      };
    };

    # Talk to your programming languages like how and when you would talk to
    # your friends: only when you need to know what value does this Python
    # expression evaluates to.
    plugins.conjure.enable = true;

    # Make them parenthesis management tolerable.
    plugins.parinfer-rust.enable = true;

    plugins.oil = {
      enable = true;
      settings = {
        columns = [
          "icon"
          "permissions"
        ];
        default_file_explorer = true;
        view_options.show_hidden = true;
        keymaps = {
          "<C-=>" = "actions.open_terminal";
        };
      };
    };

    keymaps =
      lib.optionals config.plugins.oil.enable [
        {
          key = "-";
          options.desc = "Open Oil file explorer";
          action = "<cmd>Oil<CR>";
        }

        {
          key = "<C-->";
          options.desc = "Open Oil file explorer in root directory";
          action = lib.nixvim.mkRaw ''
            function()
              require("oil").open(vim.fn.getcwd())
            end
          '';
        }
      ]
      ++ lib.optionals config.plugins.flash.enable [
        {
          key = "s";
          mode = [
            "n"
            "x"
            "o"
          ];
          options.desc = "Flash jump";
          action = lib.nixvim.mkRaw ''
            function()
              require("flash").jump()
            end
          '';
        }

        {
          key = "S";
          mode = [
            "n"
            "x"
            "o"
          ];
          options.desc = "Flash jump in treesitter nodes";
          action = lib.nixvim.mkRaw ''
            function()
              require("flash").treesitter()
            end
          '';
        }

        {
          key = "r";
          mode = "o";
          options.desc = "Remote flash jump";
          action = lib.nixvim.mkRaw ''
            function()
              require("flash").remote()
            end
          '';
        }

        {
          key = "<c-s>";
          mode = [
            "n"
            "x"
            "o"
          ];
          options.desc = "Flash treesitter search";
          action = lib.nixvim.mkRaw ''
            function()
              require("flash").treesitter_search()
            end
          '';
        }

        {
          key = "<c-s>";
          mode = "c";
          options.desc = "Toggle flash search";
          action = lib.nixvim.mkRaw ''
            function()
              require("flash").toggle()
            end
          '';
        }

        {
          key = "<c-space>";
          mode = [
            "n"
            "x"
            "o"
          ];
          options.desc = "Quick Treesitter incremental selection";
          action = lib.nixvim.mkRaw ''
            function()
              require("flash").treesitter({
                actions = {
                  ["<c-space>"] = "next",
                  ["<BS>"] = "prev",
                },
              })
            end
          '';
        }
      ]
      ++ lib.optionals config.plugins.snacks.settings.lazygit.enabled [
        {
          key = "<leader>g";
          mode = [ "n" ];
          options.desc = "Open Git client";
          action = lib.nixvim.mkRaw ''
            require("snacks").lazygit.open
          '';
        }
      ];
  };
}
