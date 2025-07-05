/*
  This is where all workflow-specific configuration should go (unless it's
  mainly composed of dconf settings).
*/
{ config, lib, pkgs, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.workflow-specific;
in
{
  options.users.foo-dogsquared.setups.workflow-specific.enable =
    lib.mkEnableOption "workflow-specific configuration for this user";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # For everything else, pls refer to the "A happy GNOME" workflow module to
    # know what workspaces has been set.
    #
    # Also, this config block comes with the following assumptions:
    #
    # * ALL workspaces has been configured with an index.
    # * The preset workspace option for the workflow module has been enabled
    # and exclusively configured around that.
    # * The default list of applications from the workflow module.
    (lib.mkIf (lib.elem "one.foodogsquared.AHappyGNOME" attrs.nixosConfig.workflows.enable or []) (
      let
        additionalShellExtensions = with pkgs; [
          gnomeExtensions.quake-terminal
        ];
        inherit (attrs.nixosConfig.workflows) workflows;
      in {
        home.packages =
          additionalShellExtensions
          ++ lib.optionals userCfg.services.backup.enable [ pkgs.pika-backup ]
          ++ lib.optionals userCfg.setups.development.enable [ pkgs.devhelp ];

        dconf.settings = lib.mkMerge [
          {
            "org/gnome/shell".enabled-extensions =
              lib.map (p: p.extensionUuid) additionalShellExtensions
              ++ workflows."one.foodogsquared.AHappyGNOME".settings."org/gnome/shell".enabled-extensions or [ ];

            "org/gnome/shell/extensions/paperwm" = {
              winprops =
                let
                  inherit (attrs.nixosConfig.workflows.workflows."one.foodogsquared.AHappyGNOME".paperwm) workspaces;

                  # A small convenience to make memorizing the index of a workspace
                  # not a thing.
                  wmIndexOf = name: workspaces.${name}.index.value;

                  # Another small convenience for making matches with Epiphany-made PWAs.
                  mkChromiumWrapperMatch = name: attr: attr // {
                    wm_class = "${config.state.packages.chromiumWrapper.pname}-${name}";
                  };

                  winpropRules =
                    lib.optionals userCfg.setups.development.enable [
                      {
                        wm_class = "org.wezfurlong.wezterm";
                        preferredWidth = "100%";
                        spaceIndex = wmIndexOf "dev";
                      }

                      (mkChromiumWrapperMatch "devdocs" {
                        spaceIndex = wmIndexOf "dev";
                      })

                      (mkChromiumWrapperMatch "gnome-devdocs" {
                        spaceIndex = wmIndexOf "dev";
                      })

                      {
                        wm_class = "Podman Desktop";
                        spaceIndex = wmIndexOf "dev";
                      }

                      {
                        wm_class = "org.gnome.Logs";
                        spaceIndex = wmIndexOf "dev";
                      }

                      {
                        wm_class = "org.gnome.Sysprof";
                        spaceIndex = wmIndexOf "dev";
                      }

                      {
                        wm_class = "com.github.markhb.Pods";
                        spaceIndex = wmIndexOf "dev";
                      }
                    ]
                    ++ lib.optionals userCfg.setups.development.creative-coding.enable [
                      {
                        wm_class = "Processing";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "scide";
                        title = "SuperCollider IDE";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "Pure Data";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "Sonic Pi";
                        spaceIndex = wmIndexOf "creative";
                      }
                    ]
                    ++ lib.optionals userCfg.programs.doom-emacs.enable [{
                      wm_class = "Emacs";
                      spaceIndex = wmIndexOf "research";
                    }]
                    ++ lib.optionals userCfg.setups.research.enable [
                      {
                        wm_class = "Zotero";
                        spaceIndex = wmIndexOf "research";
                      }

                      {
                        wm_class = "Kiwix";
                        spaceIndex = wmIndexOf "research";
                      }
                    ]
                    ++ lib.optionals config.suites.desktop.audio.enable [
                      {
                        wm_class = "Audacity";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "zrythm";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "Musescore4";
                        spaceIndex = wmIndexOf "creative";
                      }
                    ]
                    ++ lib.optionals (attrs.nixosConfig.programs.blender.enable or false) [
                      {
                        wm_class = "blender";
                        spaceIndex = wmIndexOf "creative";
                      }
                    ]
                    ++ lib.optionals config.suites.desktop.audio.pipewire.enable [
                      {
                        wm_class = "org.pipewire.Helvum";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "Carla2";
                        spaceIndex = wmIndexOf "creative";
                      }
                    ]
                    ++ lib.optionals config.suites.desktop.graphics.enable [
                      {
                        wm_class = "org.inkscape.Inkscape";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "GIMP";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "krita";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "Pureref";
                        spaceIndex = wmIndexOf "creative";
                      }

                      {
                        wm_class = "io.github.lainsce.Emulsion";
                        spaceIndex = wmIndexOf "creative";
                      }
                    ]
                    ++ lib.optionals userCfg.setups.desktop.enable [
                      (mkChromiumWrapperMatch "penpot" {
                        spaceIndex = wmIndexOf "creative";
                      })

                      (mkChromiumWrapperMatch "graphite" {
                        spaceIndex = wmIndexOf "creative";
                      })

                      (mkChromiumWrapperMatch "google-earth" {
                        spaceIndex = wmIndexOf "media";
                      })

                      (mkChromiumWrapperMatch "google-maps" {
                        spaceIndex = wmIndexOf "media";
                      })
                    ]
                    ++ lib.optionals userCfg.programs.email.thunderbird.enable [{
                      wm_class = "thunderbird";
                      preferredWidth = "100%";
                      spaceIndex = wmIndexOf "work";
                    }]
                    ++ lib.optionals userCfg.programs.vs-code.enable [{
                      wm_class = "Code";
                      preferredWidth = "100%";
                      spaceIndex = wmIndexOf "dev";
                    }]
                    ++ lib.optionals userCfg.programs.browsers.firefox.enable [{
                      wm_class = "firefox";
                      spaceIndex = wmIndexOf "media";
                    }]
                    ++ lib.optionals userCfg.programs.browsers.brave.enable [{
                      wm_class = "Brave";
                      spaceIndex = wmIndexOf "media";
                    }]
                    ++ lib.optionals userCfg.programs.browsers.google-chrome.enable [{
                      wm_class = "Google-chrome";
                      spaceIndex = wmIndexOf "media";
                    }]
                    ++ lib.optionals userCfg.setups.music.spotify.enable [
                      (mkChromiumWrapperMatch "spotify" {
                        spaceIndex = wmIndexOf "media";
                      })
                    ]
                    ++ lib.optionals userCfg.setups.business.enable [
                      (mkChromiumWrapperMatch "discord" {
                        spaceIndex = wmIndexOf "work";
                      })

                      (mkChromiumWrapperMatch "microsoft-teams" {
                        spaceIndex = wmIndexOf "work";
                      })

                      (mkChromiumWrapperMatch "zoom" {
                        spaceIndex = wmIndexOf "work";
                      })

                      (mkChromiumWrapperMatch "google-workspace" {
                        spaceIndex = wmIndexOf "work";
                      })

                      (mkChromiumWrapperMatch "messenger" {
                        spaceIndex = wmIndexOf "work";
                      })
                    ];
                in
                lib.map lib.strings.toJSON winpropRules;
            };
          }

          (lib.mkIf userCfg.programs.terminal-emulator.enable {
            "org/gnome/shell/extensions/paperwm/keybindings" = {
              # We're replacing it with the dropdown terminal hotkey.
              new-window = [ "<Super>n" ];
            };

            "org/gnome/shell/extensions/quake-terminal" = {
              terminal-shortcut = [ "<Super>Return" ];
              terminal-id = "one.foodogsquared.WeztermDropDown.desktop";
              render-on-current-monitor = true;
              always-on-top = true;
              auto-hide-window = false;
            };
          })
        ];
      })
    )
  ]);
}
