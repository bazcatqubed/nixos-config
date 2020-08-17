{ config, options, lib, pkgs, ... }:

with lib;
{
  options.modules.themes."{{ cookiecutter.name | slugify }}" = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.themes."{{ cookiecutter.name | slugify }}".enable {
    # Pass the metadata of the theme.
    modules.theme = {
      name = "{{ cookiecutter.name }}";
      version = "{{ cookiecutter.version }}";
      path = ./.;
    };

    # Enable picom compositor.
    services = {
      picom = {
        enable = true;
        fade = false;
        shadow = false;
      };

      xserver = {
        displayManager = {
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
          lightdm.greeters.mini.user = config.my.username;
          defaultSession = "none+bspwm";
        };
        enable = true;
        libinput.enable = true;
        windowManager.bspwm.enable = true;
      };
    };

    my.env.TERMINAL = "alacritty";

    my.home = {
      # Enable GTK configuration.
      gtk.enable = true;

      # Enable QT configuration.
      qt.enable = true;
      qt.platformTheme = "gtk";

      # Install all of the configurations in the XDG config home.
      xdg.configFile = mkMerge [
        (let recursiveXdgConfig = name: {
          source = ./config + "/${name}";
          recursive = true;
        }; in {
          "alacritty" = recursiveXdgConfig "alacritty";
          "bspwm" = recursiveXdgConfig "bspwm";
          "dunst" = recursiveXdgConfig "dunst";
          "polybar" = recursiveXdgConfig "polybar";
          "rofi" = recursiveXdgConfig "rofi";

          "sxhkd" = {
            source = <config/sxhkd>;
            recursive = true;
          };
        })

        (mkIf config.services.xserver.enable {
          "gtk-3.0/settings.ini".text = ''
	    [Settings]
            gtk-theme-name=Arc
            gtk-icon-theme-name=Arc
            gtk-fallback-icon-theme=gnome
            gtk-application-prefer-dark-theme=true
            gtk-cursor-theme-name=Adwaita
            gtk-xft-hinting=1
            gtk-xft-hintstyle=hintfull
            gtk-xft-rgba=none
          '';

          "gtk-2.0/gtkrc".text = ''
            gtk-theme-name="Arc"
            gtk-icon-theme-name="Arc"
            gtk-font-name="Sans 10"
            gtk-cursor-theme-name="Adwaita"
          '';
        })
      ];
    };

    my.packages = with pkgs; [
      alacritty         # Muh GPU-accelerated terminal emulator.
      dunst             # Add more annoying pop-ups on your screen!
      feh               # Meh, it's a image viewer that can set desktop background, what gives?
      gnome3.adwaita-icon-theme
      libnotify         # Library for yer notifications.
      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      })                # Add some bars to your magnum opus.
      rofi              # A ricer's best friend (one of them at least).

      # The Arc theme
      arc-icon-theme
      arc-theme
    ];

    fonts.fonts = with pkgs; [
      iosevka
      font-awesome-ttf
    ];
  };
}
