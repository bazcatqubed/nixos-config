# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# My user shell of choice because I'm not a hipster.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.shell;
in
{
  options.users.foo-dogsquared.programs.shell.enable =
    lib.mkEnableOption "configuration of foo-dogsquared's shell of choice and its toolbelt";

  config = lib.mkIf cfg.enable {
    suites.dev.shell.enable = lib.mkDefault true;

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
      bashrcExtra = lib.optionalString userCfg.dotfiles.enable (
        lib.mkAfter /* bash */ ''
          function wezterm_osc7() {
            if hash wezterm 2>/dev/null ; then
              wezterm set-working-directory 2>/dev/null && return 0
              # If the command failed (perhaps the installed wezterm
              # is too old?) then fall back to the simple version below.
            fi
            printf "\033]7;file://%s%s\033\\" "''${HOSTNAME}" "''${PWD}"
          }

          starship_precmd_user_func="wezterm_osc7"
        ''
      );
    };

    # Additional formatting thingies for your fuzzy finder.
    programs.fzf.defaultOptions = [
      "--height=40%"
      "--bind=ctrl-z:ignore"
      "--reverse"
    ];

    # Compile all of the completions.
    programs.carapace.enable = true;

    programs.atuin = {
      enable = true;
      settings = {
        auto_sync = true;
        sync_address = "http://atuin.plover.foodogsquared.one";
        sync_frequency = "10m";
        update_check = false;
        workspaces = true;
      };
    };

    # Set up with these variables.
    systemd.user.sessionVariables.PAGER = "moor";

    # Add it to the laundry list.
    services.bleachbit.cleaners = [ "bash.history" ];
  };
}
