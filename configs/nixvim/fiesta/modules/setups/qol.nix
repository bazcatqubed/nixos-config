{ config, lib, helpers, ... }:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.devenvs;
in {
  options.nixvimConfigs.fiesta.setups.qol.enable =
    lib.mkEnableOption "quality-of-life improvements";

  config = lib.mkIf cfg.enable {
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

    # Move at the speed o' sound.
    plugins.flash.enable = true;

    # Talk to your programming languages like how and when you would talk to
    # your friends: only when you need to know what value does this Python
    # expression evaluates to.
    plugins.conjure.enable = true;

    # Make them parenthesis management tolerable.
    plugins.parinfer-rust.enable = true;

    plugins.oil = {
      enable = true;
      settings = {
        columns = [ "icon" "permissions" ];
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
          action = helpers.mkRaw ''
            function()
              require("oil").open(vim.fn.getcwd())
            end
          '';
        }
      ]
      ++ lib.optionals config.plugins.flash.enable [
        {
          key = "s";
          mode = [ "n" "x" "o" ];
          options.desc = "Flash jump";
          action = helpers.mkRaw ''
            function()
              require("flash").jump()
            end
          '';
        }

        {
          key = "S";
          mode = [ "n" "x" "o" ];
          options.desc = "Flash jump in treesitter nodes";
          action = helpers.mkRaw ''
            function()
              require("flash").treesitter()
            end
          '';
        }

        {
          key = "r";
          mode = "o";
          options.desc = "Remote flash jump";
          action = helpers.mkRaw ''
            function()
              require("flash").remote()
            end
          '';
        }

        {
          key = "R";
          mode = [ "o" "x" ];
          options.desc = "Flash treesitter search";
          action = helpers.mkRaw ''
            function()
              require("flash").treesitter_search()
            end
          '';
        }

        {
          key = "<c-s>";
          mode = "c";
          options.desc = "Toggle flash search";
          action = helpers.mkRaw ''
            function()
              require("flash").toggle()
            end
          '';
        }
      ];
  };
}
