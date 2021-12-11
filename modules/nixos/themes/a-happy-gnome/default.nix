{ config, options, lib, pkgs, ... }:

# TODO: Custom dconf database which is not yet possible.
# See https://github.com/NixOS/nixpkgs/issues/54150 for more details.
let
  name = "a-happy-gnome";
  cfg = config.modules.themes.a-happy-gnome;
  dconf = pkgs.gnome3.dconf;
  customDconfDb = pkgs.stdenv.mkDerivation {
    name = "${name}-dconf-db";
    buildCommand = "${dconf}/bin/dconf compile $out ${./config/dconf}";
  };
in
{
  options.modules.themes.a-happy-gnome.enable = lib.mkEnableOption "'A happy GNOME', foo-dogsquared's configuration of GNOME desktop environment";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Since we're using KDE Connect, we'll have to use gsconnect.
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    # Don't need most of the GNOME's offering so...
    environment.gnome.excludePackages = with pkgs.gnome; [
      gedit
      eog
      geary
      totem
      epiphany
      gnome-terminal
      gnome-music
      gnome-software
      yelp
    ] ++ (with pkgs; [
      gnome-user-docs
      gnome-tour
    ]);

    programs.dconf = {
      enable = true;

      # This is an internal function which is subject to change.
      # However, this seems to be in for some time but still, be wary.
      # The function is found on `nixos/programs/dconf.nix` from nixpkgs.
      profiles.customGnomeConfig = pkgs.writeTextFile {
        name = "${name}-dconf-profile";
        text = ''
          user-db:user
          file-db:${customDconfDb}
        '';
      };
    };

    # I'm pretty sure this is already done but just to make sure.
    services.gnome.chrome-gnome-shell.enable = true;

    environment.systemPackages = with pkgs; [
      # It is required for custom menus in extensions.
      gnome-menus

      # My preferred extensions.
      gnomeExtensions.arcmenu
      gnomeExtensions.gsconnect
      gnomeExtensions.x11-gestures

      # Setting up Pop shell.
      gnome-shell-extension-pop-shell
      pop-launcher
      pop-launcher-plugin-duckduckgo-bangs
    ];
  };
}
