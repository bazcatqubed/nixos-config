# Makes you infinitesimally productive.
{ config, lib, pkgs, foodogsquaredLib, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.desktop;

  elementalWarriorVersion = "9.13";
  elementalWarriorWine = pkgs.fetchzip {
    url = "https://github.com/Twig6943/wine/releases/download/${elementalWarriorVersion}/ElementalWarriorWine-x86_64.tar.gz";
    hash = "sha256-skiG6wVeU8k/lKX4h35OM7YMcyB2dOe7oN4DmpCDWek=";
  };
in {
  options.users.foo-dogsquared.setups.desktop.enable =
    lib.mkEnableOption "a set of usual desktop productivity services";

  config = lib.mkIf cfg.enable {
    state.ports.activitywatch.value = 5600;

    home.packages = with pkgs; [
      komikku
      bitwarden-cli bitwarden-desktop

      # Games make you productive, right?
      aisleriot
      crosswords

      freecad
      kicad
      leocad
      librecad

      aider-chat-full
    ];

    users.foo-dogsquared = {
      programs = {
        browsers.brave.enable = true;
        browsers.google-chrome.enable = true;
        browsers.firefox.enable = true;
      };
    };

    # Install all of the desktop stuff.
    suites.desktop = {
      enable = true;
      audio.enable = true;
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
        topdirs = "~/Downloads ~/Documents ~/library";
        "skippedNames+" = let inherit (config.state.paths) ignoreDirectories;
        in lib.concatStringsSep " " ignoreDirectories;

        "~/library/projects" = {
          "skippedNames+" = ".editorconfig .gitignore result flake.lock go.sum";
        };

        "~/library/projects/software" = { "skippedNames+" = "target result"; };
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

    users.foo-dogsquared.programs.custom-homepage.sections.services.links =
      lib.singleton {
        url = "http://localhost:${
            builtins.toString config.state.ports.activitywatch.value
          }";
        text = "Telemetry server";
      };

    wrapper-manager.packages.web-apps.wrappers = lib.mkIf userCfg.programs.browsers.google-chrome.enable (
      let
        inherit (foodogsquaredLib.wrapper-manager) wrapChromiumWebApp commonChromiumFlags;

        chromiumPackage = config.state.packages.chromiumWrapper;

        mkFlags = name: commonChromiumFlags ++ [
          "--user-data-dir=${config.xdg.configHome}/${chromiumPackage.pname}-${name}"
        ];
      in {
        penpot = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "penpot";
          url = "https://design.penpot.app";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            icon = pkgs.fetchurl {
              url = "https://github.com/penpot.png?s=460";
              hash = "sha256-Ft9AIWyMe8UcENeBLnKtxNW2DfLMwMqTYTha/FtEpwI=";
            };
            desktopName = "Penpot";
            genericName = "Wireframing Tool";
            categories = [ "Graphics" ];
            comment = "Design and code collaboration tool";
            keywords = [ "Design" "Wireframing" "Website" ];
          };
        };

        graphite = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "graphite";
          url = "https://editor.graphite.rs";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
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

        google-maps = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "google-maps";
          url = "https://maps.google.com";
          imageHash = "sha512-vjo1kMyvm/q/N6zF+hwgRYuIjjJ3MHjgNVGQd4SbvMZZzS3Df+CzqCKDHPPfPYjKwSA+ustuIlEzE8FrmKDgzA==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "Google Maps";
            genericName = "Map Viewer";
            keywords = [
              "Maps"
              "Geographic"
              "Locations"
              "Geospatial Data"
              "Satellite Imagery"
            ];
          };
        };

        google-earth = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "google-earth";
          url = "https://earth.google.com";
          imageHash = "sha512-nNhrwyQStOU/yMDVcFP/qL2QOLORynhbGG0tu4Yh5Y8x/FfhCAR8+sxVfKQ1KG2LDopo6icUrSWn0bshrSlWQw==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
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

        netflix = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "netflix";
          url = "https://netflix.com";
          imageHash = "sha512-V5TfMR+Je7QNS8Nsh+M8M0I7KU2oxDnqPVcu1LS2wa/gkf67V6fQeWW0Q5AzzIdNbMy1Vp9CEw0DkAotRcvkDg==";
          appendArgs = mkFlags name ++ [
            "--enable-nacl"
          ];
          xdg.desktopEntry.settings = {
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
      }
    );

    # We're doing in this way since Bottles crash out when the runners are
    # symlinks.
    home.mutableFile."${config.xdg.dataHome}/bottles/runners/elemental-warrior-${elementalWarriorVersion}" =
      lib.mkIf (attrs.nixosConfig.suites.desktop.windows-compatibility.enable  or false) {
        type = "copy";
        url = elementalWarriorWine;
      };
  };
}
