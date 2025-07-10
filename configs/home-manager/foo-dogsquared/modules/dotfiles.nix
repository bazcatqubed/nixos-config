{ config, lib, pkgs, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.dotfiles;

  projectsDir = config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR;

  dotfiles = "${projectsDir}/packages/dotfiles";
  dotfilePackages = import "${dotfiles}/_packages/nix" { inherit pkgs; };
  dotfiles' = config.lib.file.mkOutOfStoreSymlink
    config.home.mutableFile."${dotfiles}".path;
  getDotfiles = path: "${dotfiles'}/${path}";
in {
  options.users.foo-dogsquared.dotfiles.enable =
    lib.mkEnableOption "custom outside dotfiles for other programs";

  config = lib.mkIf cfg.enable (lib.mkMerge [
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
        shfmt
        cmake

        # Just assume that there is no clipboard thingy that is already managed
        # within this home-manager configuration.
        wl-clipboard
        xclip
      ];
    })

    (lib.mkIf config.programs.nushell.enable {
      home.file."${config.xdg.dataHome}/nushell/vendor/autoload".source =
        getDotfiles "nu/autoload";

      home.sessionVariables = {
        FZF_ALT_C_COMMAND = "${lib.getExe' pkgs.fd "fd"} --type directory --unrestricted";
        FZF_ALT_SHIFT_C_COMMAND = "${lib.getExe' pkgs.fd "fd"} --type directory --full-path --max-depth 4 . ../";
      };
    })

    (lib.mkIf config.programs.helix.enable {
      xdg.configFile.helix.source = getDotfiles "helix";
    })

    (lib.mkIf (lib.elem "one.foodogsquared.AHappyGNOME" attrs.nixosConfig.workflows.enable or []) {
      xdg.dataFile."nautilus/scripts" = {
        source = getDotfiles "nautilus/scripts";
        recursive = true;
      };

      home.packages = with dotfilePackages; [
        fds-nautilus-extensions
      ];
    })
  ]);
}
