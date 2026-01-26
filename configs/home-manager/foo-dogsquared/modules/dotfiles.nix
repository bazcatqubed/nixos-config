{
  config,
  lib,
  pkgs,
  ...
}@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.dotfiles;

  projectsDir = config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR;

  dotfiles = "${projectsDir}/packages/dotfiles";
  dotfilePackages = import "${dotfiles}/_packages/nix" { inherit pkgs; };
  dotfiles' = config.lib.file.mkOutOfStoreSymlink config.home.mutableFile."${dotfiles}".path;
  getDotfiles = path: "${dotfiles'}/${path}";
in
{
  options.users.foo-dogsquared.dotfiles = {
    enable = lib.mkEnableOption "custom outside dotfiles for other programs";

    reimplementation.enable = lib.mkEnableOption null // {
      description = ''
        Whether to enable various reimplementations found in the dotfiles.

        :::{.caution}
        May disable some configurations and replacing them with their own.
        :::
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.mutableFile.${dotfiles} = {
          url = "https://github.com/foo-dogsquared/dotfiles.git";
          type = "git";
        };

        home.sessionPath = [ "${config.home.mutableFile.${dotfiles}.path}/bin" ];
      }

      (lib.mkIf (userCfg.programs.doom-emacs.enable) {
        xdg.configFile.doom.source = getDotfiles "emacs";
      })

      (lib.mkIf (userCfg.setups.development.enable) {
        xdg.configFile = {
          kitty.source = getDotfiles "kitty";
          wezterm.source = getDotfiles "wezterm";
        };
      })

      (lib.mkIf (userCfg.programs.browsers.misc.enable) {
        xdg.configFile.nyxt.source = getDotfiles "nyxt";
      })

      # Comes with a heavy assumption that the Neovim configuration found in this
      # home-manager environment will not write to the XDG config directory.
      (lib.mkIf (config.programs.neovim.enable) {
        xdg.configFile.nvim.source = getDotfiles "nvim";
        xdg.configFile.neovide.source = getDotfiles "neovide";

        home.packages = with pkgs; [ neovide ];

        programs.neovim.extraPackages = with pkgs; [
          charm-freeze
          luarocks
          lua5_1
          shfmt
          cmake

          # Just assume that there is no clipboard thingy that is already managed
          # within this home-manager configuration.
          wl-clipboard
          xclip
        ];
      })

      (lib.mkIf config.programs.nushell.enable {
        programs.nushell.environmentVariables.NU_LIB_DIRS =
          lib.singleton "${config.xdg.configHome}/nushell/foodogsquared";

        home.file."${config.xdg.configHome}/nushell/autoload".source = getDotfiles "nu/autoload";
        home.file."${config.xdg.configHome}/nushell/scripts".source = getDotfiles "nu/scripts";

        home.sessionVariables = {
          FZF_ALT_C_COMMAND = "${lib.getExe' pkgs.fd "fd"} --type directory --unrestricted";
          FZF_ALT_SHIFT_C_COMMAND = "${lib.getExe' pkgs.fd "fd"} --type directory --full-path --max-depth 4 . ../";
        };
      })

      (lib.mkIf (lib.elem "one.foodogsquared.AHappyGNOME" attrs.nixosConfig.workflows.enable or [ ]) {
        xdg.dataFile."nautilus/scripts" = {
          source = getDotfiles "nautilus/scripts";
          recursive = true;
        };

        # Despite the option to install through a build system upstream, we'll
        # use this similarly to the other dotfiles since I always modify them.
        xdg.dataFile."nautilus-python/extensions" = {
          source = getDotfiles "nautilus-extensions";
          recursive = true;
        };
      })

      (lib.mkIf (cfg.reimplementation.enable && config.programs.helix.enable) {
        # Force unset them configs for our dotfiles.
        programs.helix.settings = lib.mkForce { };

        xdg.configFile.helix.source = getDotfiles "helix";
      })

      # We're just replacing it with our own implmentation of the following
      # programs.
      (let
        hasNushellAsDefaultShell =
          attrs.nixosConfig.users.users.${config.home.username}.shell or null == config.programs.nushell.package;
      in lib.mkIf (cfg.reimplementation.enable && hasNushellAsDefaultShell) {
        # Replacing it with our own implementation of autojump.
        programs.zoxide.enable = lib.mkForce false;
      })
    ]
  );
}
