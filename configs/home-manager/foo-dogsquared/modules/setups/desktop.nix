# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# Makes you infinitesimally productive.
{
  config,
  lib,
  pkgs,
  foodogsquaredLib,
  ...
}@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.desktop;
in
{
  options.users.foo-dogsquared.setups.desktop.enable =
    lib.mkEnableOption "a set of usual desktop productivity services";

  config = lib.mkIf cfg.enable {
    state.ports.activitywatch.value = 5600;

    home.packages = with pkgs; [
      komikku
      bitwarden-cli # Manage them passwords terminally.
      bitwarden-desktop # Manage them passwords on a stick.
      comaps # Triangulating them locations.
      parabolic # Download them clips.

      # Games make you productive, right?
      aisleriot
      crosswords

      freecad
      leocad
    ];

    users.foo-dogsquared = {
      programs = {
        browsers.brave.enable = true;
        browsers.google-chrome.enable = true;
        browsers.firefox.enable = true;
      };
    };

    dconf.settings = {
      "info/febvre/Komikku".pinned-servers = [
        "mangabin"
        "tapas"
        "webtoon"
        "xkcd"
        "peppercarrot"
      ];
    };

    # Install all of the desktop stuff.
    suites.desktop = {
      enable = true;
      audio.enable = userCfg.setups.music.enable;
      audio.pipewire.enable = true;
      graphics.enable = true;
      video.enable = true;
      documents.enable = true;
    };

    # Make it rain with fonts.
    fonts.fontconfig.enable = true;

    # Forcibly set the user directories.
    xdg.userDirs.enable = true;

    # Self-inflicted telemetry.
    services.activitywatch = {
      enable = true;
      settings.server.port = config.state.ports.activitywatch.value;
      watchers = {
        aw-watcher-afk.package = pkgs.activitywatch;
        aw-watcher-window.package = pkgs.activitywatch;
      };
    };

    # Clean up your mess
    services.bleachbit = {
      enable = true;
      cleaners = [
        "winetricks.temporary_files"
        "wine.tmp"
        "discord.history"
        "google_earth.temporary_files"
        "google_toolbar.search_history"
        "thumbnails.cache"
        "zoom.logs"
        "vim.history"
      ];
      withChatCleanup = true;
      withBrowserCleanup = true;
    };

    # My preferred file indexing service.
    services.recoll = {
      enable = true;
      startAt = "daily";
      settings = {
        topdirs =
          let
            inherit (config.xdg) userDirs;
          in
          builtins.toString [
            userDirs.music
            userDirs.documents
            userDirs.extraConfig.PROJECTS
            userDirs.download
          ];

        "skippedNames+" =
          let
            inherit (config.state.paths) ignoreDirectories;
          in
          lib.concatStringsSep " " ignoreDirectories;

        "${config.xdg.userDirs.extraConfig.PROJECTS}" = {
          "skippedNames+" = ".editorconfig .gitignore result flake.lock go.sum";
        };

        "${config.xdg.userDirs.extraConfig.PROJECTS}/software" = {
          "skippedNames+" = "target result";
        };
      };
    };

    # My daily digital newspaper.
    services.matcha = {
      enable = true;
      settings = {
        opml_file_path = "${config.xdg.userDirs.documents}/feeds.opml";
        markdown_dir_path = "${config.xdg.userDirs.documents}/Matcha";
      };
      startAt = "daily";
    };

    users.foo-dogsquared.programs.custom-homepage.sections.services.links = lib.singleton {
      url = "http://localhost:${builtins.toString config.state.ports.activitywatch.value}";
      text = "Telemetry server";
    };

    wrapper-manager.packages.web-apps = lib.mkIf userCfg.programs.browsers.google-chrome.enable (
      {
        hmConfig,
        config,
        foodogsquaredLib,
        ...
      }:
      {
        programs.chromium-web-apps.apps = lib.mkMerge [
          (lib.mkIf hmConfig.suites.desktop.graphics.enable {
            penpot = {
              baseURL = "design.penpot.app";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "penpot";
              desktopEntrySettings = {
                icon = pkgs.fetchurl {
                  url = "https://github.com/penpot.png?s=460";
                  hash = "sha256-Ft9AIWyMe8UcENeBLnKtxNW2DfLMwMqTYTha/FtEpwI=";
                };
                desktopName = "Penpot";
                genericName = "Wireframing Tool";
                categories = [ "Graphics" ];
                comment = "Design and code collaboration tool";
                keywords = [
                  "Design"
                  "Wireframing"
                  "Website"
                ];
              };
            };

            graphite = {
              baseURL = "editor.graphite.rs";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "graphite";
              desktopEntrySettings = {
                icon = pkgs.fetchurl {
                  url = "https://static.graphite.rs/logos/graphite-logo-color-480x480.png";
                  hash = "sha256-ZyeWHvF5/7G/Lhxln6+WuUrrZvqBBhj8Uz9MkraDkbo=";
                };
                desktopName = "Graphite";
                genericName = "Procedural Generation Image Editor";
                categories = [ "Graphics" ];
                comment = "Procedural toolkit for 2D content creation";
                keywords = [
                  "Procedural Generation"
                  "Photoshop"
                  "Illustration"
                  "Photo Editing"
                ];
              };
            };

            canva = {
              baseURL = "canva.com";
              imageHash = "sha512-jpXHNmTRi7Up6nK4i1//H0DyTE8ADRvcA0wvnB2rZ2Td2t3qw6eSUM8mIT7FbYqbQ5sDAfKGpeD3VQVcMx6f8Q==";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "canva";
              desktopEntrySettings = {
                desktopName = "Canva";
                genericName = "Visual Design Editor";
                comment = "Graphic design for non-designers";
                keywords = [
                  "Design"
                  "Visual Arts"
                  "Whiteboard"
                ];
              };
            };

            coolors = {
              baseURL = "coolors.co";
              imageHash = "sha512-dWfZaUNuMP9C57PxhOWhFugcOdz4ol/BMLqe3DklkbHvJkMUKD4INlOZu26PcTV+NKWiSjyVdQjS6eRRoNxgRw==";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "coolors";
              desktopEntrySettings = {
                desktopName = "Coolors";
                genericName = "Color Palette Generator";
                comment = "Palette generator";
                keywords = [
                  "Design"
                  "Visual Arts"
                ];
              };
            };
          })

          (lib.mkIf hmConfig.suites.desktop.documents.enable {
            google-maps = {
              baseURL = "maps.google.com";
              imageHash = "sha512-vjo1kMyvm/q/N6zF+hwgRYuIjjJ3MHjgNVGQd4SbvMZZzS3Df+CzqCKDHPPfPYjKwSA+ustuIlEzE8FrmKDgzA==";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "google-maps";
              desktopEntrySettings = {
                desktopName = "Google Maps";
                genericName = "Map Viewer";
                comment = "Online map viewer";
                keywords = [
                  "Maps"
                  "Geographic"
                  "Locations"
                  "Geospatial Data"
                  "Satellite Imagery"
                ];
              };
            };

            google-earth = {
              baseURL = "earth.google.com";
              imageHash = "sha512-nNhrwyQStOU/yMDVcFP/qL2QOLORynhbGG0tu4Yh5Y8x/FfhCAR8+sxVfKQ1KG2LDopo6icUrSWn0bshrSlWQw==";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "google-earth";
              desktopEntrySettings = {
                desktopName = "Google Earth";
                genericName = "3D Planet Viewer";
                comment = "View the earth in 3D";
                keywords = [
                  "Maps"
                  "Geographic"
                  "Locations"
                ];
              };
            };
          })

          (lib.mkIf hmConfig.suites.desktop.documents.enable {
            snapchat = {
              baseURL = "snapchat.com";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "snapchat";
              desktopEntrySettings = {
                desktopName = "Snapchat";
                genericName = "Messaging client";
                keywords = [
                  "Chat"
                  "Instant Messaging"
                ];
                icon = pkgs.fetchurl {
                  url = "https://upload.wikimedia.org/wikipedia/en/c/c4/Snapchat_logo.svg";
                  hash = "sha256-c7gR2q3bbqwd3n8RCFAUjKJzyxCOT0zZWsHU0bcu6rI=";
                };
              };
            };

            whatsapp = {
              baseURL = "web.whatsapp.com";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "whatsapp";
              desktopEntrySettings = {
                desktopName = "WhatsApp";
                genericName = "Messaging Client";
                comment = "Web chat that will let everyone know everything";
                keywords = [
                  "Chat"
                  "Instant Messaging"
                ];
                icon = pkgs.fetchurl {
                  url = "https://upload.wikimedia.org/wikipedia/commons/4/4c/WhatsApp_Logo_green.svg";
                  hash = "sha256-r86bMymoW0YuC0Ag6aqBrlFU+Etko2U931MOD5Q1Ebs=";
                };
              };
            };

            telegram = {
              baseURL = "web.telegram.org";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "telegram";
              imageHash = "sha512-qxxTdmmM6GUWqoNLjs8CxFDUd5RBY8K3icWVaTBcQsUe/3saBaKD9e82Q7rG5rICne8dAnYRWQbtFJtGh2zy+Q==";
              desktopEntrySettings = {
                desktopName = "Telegram";
                genericName = "Messaging Client";
                comment = "Messaging client for your ILLEGAL ACTIVITIES";
                keywords = [
                  "Chat"
                  "Instant Messaging"
                ];
              };
            };

            netflix = {
              baseURL = "netflix.com";
              imageHash = "sha512-V5TfMR+Je7QNS8Nsh+M8M0I7KU2oxDnqPVcu1LS2wa/gkf67V6fQeWW0Q5AzzIdNbMy1Vp9CEw0DkAotRcvkDg==";
              flags = foodogsquaredLib.extra.mkCommonChromiumFlags "netflix" ++ [
                "--enable-nacl"
              ];
              desktopEntrySettings = {
                desktopName = "Netflix";
                genericName = "Online Video Stream Client";
                comment = "Video stream from a wide library of shows";
                categories = [ "AudioVideo" ];
                keywords = [
                  "TV Shows"
                  "Anime"
                  "Documentaries"
                  "KDrama"
                  "CDrama"
                  "JDrama"
                ];
              };
            };
          })
        ];
      }
    );
  };
}
