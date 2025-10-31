{ config, lib, pkgs, options, foodogsquaredLib, ... }@attrs:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.development;
in {
  options.users.foo-dogsquared.setups.development = {
    enable = lib.mkEnableOption "foo-dogsquared's software development setup";

    creative-coding.enable =
      lib.mkEnableOption "foo-dogsquared's creative coding setup";

    gamedev.enable =
      lib.mkEnableOption "foo-dogsquared's gamedev suite";

    math.enable =
      lib.mkEnableOption "foo-dogsquared's meth suite";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      state.packages.pager = config.programs.bat.package;

      state.paths.ignoreDirectories = [
        "node_modules" # For Node projects.
        "result" # For Nix builds.
        "target" # For Rust builds.
      ];

      users.foo-dogsquared.programs = {
        shell.enable = true;
        nushell.enable = true;
        git = {
          enable = lib.mkDefault true;
          instaweb.enable = true;
        };
        email = {
          aerc.enable = lib.mkDefault true;
          himalaya.enable = lib.mkDefault true;
        };
        jujutsu.enable = lib.mkDefault true;
        keys.gpg.enable = true;
        keys.ssh.enable = true;
        terminal-multiplexer.enable = lib.mkDefault true;
        terminal-emulator.enable = lib.mkDefault true;

        # Enable them text editors.
        nixvim.enable = true;
        vs-code.enable = true;
      };

      suites.dev = {
        enable = true;
        extras.enable = true;
        coreutils-replacement.enable = true;
        shell.enable = true;
        servers.enable = true;
      };

      # Rootless podman.
      services.podman = {
        enable = true;
        enableTypeChecks = false;
        autoUpdate = {
          enable = true;
          onCalendar = "weekly";
        };
      };

      users.foo-dogsquared.programs.custom-homepage.sections.services.links =
        let
          hasCockpitEnabled =
            attrs.nixosConfig.services.cockpit.enable or false;
        in lib.optionals hasCockpitEnabled (lib.singleton {
          url = "http://localhost:${
              builtins.toString attrs.nixosConfig.services.cockpit.port
            }";
          text = "Cockpit WebUI";
        });

      systemd.user.sessionVariables = {
        MANPAGER = "nvim +Man!";
        EDITOR = "nvim";
      };

      home.packages = with pkgs; [
        comma # You come and go.
        cachix # Compile no more by using someone's binary cache!
        regex-cli # Save some face of confusion for yourself.
        dt # Get that functional gawk.
        jq # Get that JSON querying tool.
        fq # Get that binary querying tool.
        recode # Convert between different encodings.
        go-migrate # Go potential migraines.
        oils-for-unix # Rev them up, reverent admin.
        lnav # Navigate with some logs like what some pirates do.
        inotify-tools # I notify things with tools like these.
        watchman # He ain't a superhero though, he's a creeper (for your files that is).
        devbox # Create a Nix devshell without Nixlang.

        # Testing REST and all about backend development.
        httpie
        httpie-desktop
        hurl
        grpcurl
        steampipe

        # Testing out Kubernetes.
        kind

        # Testing out LLMs.
        plandex

        # Testing out your web app #532.
        dbeaver-bin
        beekeeper-studio
        turso-cli
      ]
      ++ lib.optionals (attrs.nixosConfig.suites.vpn.personal.enable or false) [
        trayscale
      ]
      ++ lib.optionals (config.services.podman.enable || attrs.nixosConfig.virtualisation.podman.enable or false) [
        podman-desktop
        pods
        toolbox
        ptyxis
      ];

      # Text editors galore.
      programs.helix.enable = true;
    }

    (lib.mkIf (config.services.podman.enable && !(attrs.nixosConfig.programs.distrobox.enable or false)) {
      programs.distrobox = {
        enable = true;
        settings = {
          container_additional_volumes = [
            "/nix/store:/nix/store:ro"
          ]
          ++ lib.optionals (attrs.nixosConfig.home-manager.useUserPackages or false) [
            "/etc/profiles/per-user:/etc/profiles/per-user:ro"
            "/etc/static:/etc/static:ro"
          ]
          ++ lib.optionals (builtins.storeDir != "/nix/store") [
            builtins.storeDir
          ];
        };
      };
    })

    (lib.mkIf (attrs.nixosConfig.services.guix.enable or false) {
      home.sessionPath = lib.singleton "${config.xdg.configHome}/guix/current/bin";
    })

    (lib.mkIf (!config.programs.nixvim.enable or false) {
      programs.neovim = {
        enable = true;
        vimAlias = true;
        vimdiffAlias = true;

        withNodeJs = true;
        withPython3 = true;
        withRuby = true;
      };
    })

    (lib.mkIf userCfg.programs.browsers.firefox.enable {
      home.packages = with pkgs; [ (lowPrio firefox-devedition) ];
    })

    (lib.mkIf userCfg.programs.git.enable {
      home.packages = with pkgs; [
        diffoscope # An oversized caffeine grinder.
        meld # Make a terminal dweller melt.
      ];

      programs.git.extraConfig = {
        difftool.prompt = false;
        diff.tool = "diffoscope";
        diff.guitool = "meld";

        # Yeah, let's use this oversized diff tool, shall we?
        # Also, this config is based from this tip.
        # https://lists.reproducible-builds.org/pipermail/diffoscope/2016-April/000193.html
        difftool."diffoscope".cmd = ''
          if [[ $LOCAL = /dev/null ]]; then diffoscope --new-file $REMOTE; else diffoscope $LOCAL $REMOTE; fi
        '';

        difftool."diffoscope-html".cmd = ''
          if [[ $LOCAL = /dev/null ]]; then diffoscope --new-file $REMOTE --html - | cat; else diffoscope $LOCAL $REMOTE --html - | cat; fi
        '';
      };
    })

    (lib.mkIf userCfg.programs.browsers.google-chrome.enable {
      wrapper-manager.packages.web-apps.wrappers = let
        inherit (foodogsquaredLib.wrapper-manager) wrapChromiumWebApp commonChromiumFlags;

        chromiumPackage = config.state.packages.chromiumWrapper;

        mkFlags = name: commonChromiumFlags ++ [
          "--user-data-dir=${config.xdg.configHome}/${chromiumPackage.pname}-${name}"
        ];
      in {
        devdocs = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "devdocs";
          baseURL = "devdocs.io";
          imageHash = "sha512-FQWUz7CyFhpRi6iJN2LZUi8pV6AL8+74aynrTbVkMnRUNO9bo9BB6hgvOCW/DQvCl1a2SZ0iAxk2ULZKAVR0MA==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "DevDocs";
            genericName = "Documentation Browser";
            categories = [ "Development" ];
            comment = "One-stop shop for API documentation";
            keywords = [ "Documentation" "HTML" "CSS" "JavaScript" ];
          };
        };

        gnome-devdocs = wrapChromiumWebApp rec {
          inherit chromiumPackage;
          name = "gnome-devdocs";
          baseURL = "gjs-docs.gnome.org";
          imageHash = "sha512-FQWUz7CyFhpRi6iJN2LZUi8pV6AL8+74aynrTbVkMnRUNO9bo9BB6hgvOCW/DQvCl1a2SZ0iAxk2ULZKAVR0MA==";
          appendArgs = mkFlags name;
          xdg.desktopEntry.settings = {
            desktopName = "GNOME DevDocs";
            genericName = "Documentation Browser";
            categories = [ "Development" ];
            comment = "DevDocs instance for GNOME tech stack";
            keywords = [ "Documentation" "GTK" "GJS" "glib" ];
          };
        };
      };
    })

    (lib.mkIf (userCfg.setups.desktop.enable && pkgs.stdenv.isLinux) {
      home.packages = with pkgs;
        [
          d-spy # Some GNOME dev probably developed this.
          bustle # Hustle and...
        ];
    })

    (lib.mkIf cfg.creative-coding.enable {
      home.packages = with pkgs; [
        decker
        uxn
        supercollider-with-plugins
        sonic-pi
        processing
        (puredata-with-plugins (with pkgs; [ zexy ]))
        shader-slang
        material-maker
      ];

      xdg.desktopEntries.decker = {
        name = "Decker";
        genericName = "Multimedia Sketchbook";
        exec = lib.getExe pkgs.decker;
        icon = "${pkgs.decker.src}/icon_512x512.png";
      };
    })

    (lib.mkIf cfg.gamedev.enable {
      home.packages = with pkgs; [
        tic-80-unstable
        godot_4
        godot_4-export-templates
        gdtoolkit_4
      ];
    })

    (lib.mkIf cfg.math.enable {
      home.packages = with pkgs; [
        geogebra6
      ];

      programs.python.modules = ps: with ps; [
        jupyter
        jupyter-book
        notebook
      ];
    })
  ]);
}
