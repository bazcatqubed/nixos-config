{ config, options, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    borgmatic
    borgbackup
    ncmpcpp
  ];

  fonts.fontconfig.enable = true;

  # My specific usual stuff.
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
    userName = "foo-dogsquared";
    userEmail = "foo.dogsquared@gmail.com";
  };

  # My music player setup, completely configured with Nix!
  services.mpd = {
    enable = true;
    musicDirectory = "$HOME/library/music";
  };

  # My custom modules.
  modules = {
    bleachbit.enable = true;
    i18n.enable = true;
    dev = {
      enable = true;
      shell.enable = true;
    };
    editors.emacs.enable = true;
    desktop = {
      enable = true;
      graphics.enable = true;
      audio.enable = true;
      multimedia.enable = true;
    };
    research.enable = true;
  };
}
