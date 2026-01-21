{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.research;

  # Given an attribute set of jobs that contains a list of objects with
  # their names and URL, create an attrset suitable for declaring the
  # archiving jobs of several services for `services.yt-dlp`,
  # `services.gallery-dl`, and `services.archivebox`.
  mkJobs = { extraArgs ? [ ], db }:
    let
      days = [
        "Monday"
        "Tuesday"
        "Wednesday"
        "Thursday"
        "Friday"
        "Saturday"
        "Sunday"
      ];
      categories = lib.zipListsWith (index: category: {
        inherit index;
        data = category;
      }) (lib.lists.range 1 (lib.length (lib.attrValues db)))
        (lib.mapAttrsToList (name: value: {
          inherit name;
          inherit (value) subscriptions extraArgs;
        }) db);
      jobsList = lib.map (category:
        let jobExtraArgs = lib.attrByPath [ "data" "extraArgs" ] [ ] category;
        in {
          name = category.data.name;
          value = {
            extraArgs = extraArgs ++ jobExtraArgs;
            urls = lib.map (subscription: subscription.url)
              category.data.subscriptions;
            startAt =
              lib.elemAt days (lib.mod category.index (lib.length days));
          };
        }) categories;
    in lib.listToAttrs jobsList;
in {
  options.users.foo-dogsquared.setups.research = {
    enable =
      lib.mkEnableOption "foo-dogsquared's usual toolbelt for research";

    writing.enable =
      lib.mkEnableOption "writing suite";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      users.foo-dogsquared = {
        programs.password-utilities.enable = lib.mkDefault true;
        services.archivebox.enable = true;
      };

      state.ports.syncthing.value = 8384;

      home.packages = with pkgs; [
        curl # The general purpose downloader.
        fanficfare # It's for the badly written fanfics.
        gallery-dl # More potential for your image collection.
        internetarchive # All of the potential vintage collection of questionable materials at your fingertips.
        kiwix # Offline reader for your fanon wiki.
        localsend # Local network syncing.
        monolith # Archive webpages into a single file.
        qbittorrent # The pirate's toolkit for downloading Linux ISOs.
        sherlock # Make a profile of your *target*.
        wget # Who would've think a simple tool can be made for this purpose?
        yt-dlp # The general purpose video downloader.
        zotero # It's actually good at archiving despite not being a researcher myself.
      ]
        ++ lib.optionals userCfg.setups.desktop.enable (with pkgs; [
          parabolic
        ]);

      programs.anki = {
        enable = true;
        addons = with pkgs.ankiAddons; [
          anki-connect
          adjust-sound-volume
          reviewer-refocus-card
        ];
      };

      services.syncthing = {
        enable = true;
        extraOptions = [
          "--gui-address=http://localhost:${
            builtins.toString config.state.ports.syncthing.value
          }"
        ];
      };

      xdg.mimeApps.defaultApplications = {
        "application/vnd.anki" = [ "anki.desktop" ];
      };

      xdg.autostart.entries =
        lib.singleton (foodogsquaredLib.xdg.getXdgDesktop pkgs.zotero "zotero");

      users.foo-dogsquared.programs.custom-homepage.sections.services.links =
        lib.singleton {
          url = "http://localhost:${
              builtins.toString config.state.ports.syncthing.value
            }";
          text = "Local sync server";
        };

      programs.python.modules = ps: with pkgs.swh; [
        swh-core
        swh-fuse
        swh-model
        swh-web-client
      ];
    }

    (lib.mkIf userCfg.programs.shell.enable {
      programs.atuin.settings.history_filter = [
        "^curl"
        "^wget"
        "^monolith"
        "^sherlock"
        "^yt-dlp"
        "^yt-dl"
        "^gallery-dl"
        "^archivebox"
        "^fanficfare"
      ];
    })

    (lib.mkIf cfg.writing.enable {
      # We want the doom and gloom of writing.
      users.foo-dogsquared.programs.doom-emacs.enable = lib.mkDefault true;

      # Enable this subset of desktop suite.
      suites.desktop.documents.enable = true;

      home.packages = with pkgs; [
        vale # Make writing docs a welcoming night.
        goldendict-ng # A golden dictionary for perfecting your diction.
        ascii-draw # Super emoticons.
        # exhibit # View them 3D boats.
        eloquent # Reach a higher caliber for your wordsmithing, indubitably.
        harper # A grammer checker with yer' Grandma..er.
      ]
        ++ lib.optionals config.programs.typst.enable [
          tinymist
        ]
        ++ lib.optionals config.programs.texlive.enable [
          lyx
        ];

      # The heaviest installation of them all, I swear.
      programs.texlive = {
        enable = true;
        package = pkgs.texliveMedium;
      };

      # Lighter version of LaTeX if you want to be a hipster in document
      # typesetting.
      programs.typst = {
        enable = true;
        extraPackages = p: with p; [
          cetz
          unify
          glossarium
        ];
      };
    })
  ]);
}
