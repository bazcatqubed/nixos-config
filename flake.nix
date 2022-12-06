{
  description = "foo-dogsquared's abomination of a NixOS configuration";

  nixConfig = {
    extra-substituters =
      "https://nix-community.cachix.org https://foo-dogsquared.cachix.org";
    extra-trusted-public-keys =
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E=";
  };

  inputs = {
    # I know NixOS can be stable but we're going cutting edge, baybee! While
    # `nixpkgs-unstable` branch could be faster delivering updates, it is
    # looser when it comes to stability for the entirety of this configuration.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # We're using these libraries for other functions.
    flake-utils.url = "github:numtide/flake-utils";

    # My personal dotfiles.
    dotfiles.url = "github:foo-dogsquared/dotfiles";
    dotfiles.flake = false;

    # Managing home configurations.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";

    # This is what AUR strives to be.
    nur.url = "github:nix-community/NUR";

    # Running unpatched binaries on NixOS! :O
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.inputs.flake-utils.follows = "flake-utils";

    # Generate your NixOS systems to various formats!
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Managing your secrets.
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Easy access to development environments.
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";

    # We're getting more unstable there should be a black hole at my home right
    # now. Also, we're seem to be collecting text editors like it is Pokemon.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.flake-utils.follows = "flake-utils";

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";

    # Guix in NixOS?!
    guix-overlay.url = "github:foo-dogsquared/nix-overlay-guix";

    # The more recommended Rust overlay so I'm going with it.
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";

    # Generating an entire flavored themes with Nix?
    nix-colors.url = "github:misterio77/nix-colors";

    # Deploying stuff with Nix. This is becoming a monorepo for everything I
    # need and I'm liking it.
    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      # The order here is important(?).
      overlays = [
        # Put my custom packages to be available.
        self.overlays.default

        # Neovim nightly!
        inputs.neovim-nightly-overlay.overlay

        # Emacs unstable version!
        inputs.emacs-overlay.overlay

        # Rust overlay for them ease of setting up Rust toolchains.
        inputs.rust-overlay.overlays.default

        # Access to NUR.
        inputs.nur.overlay

        inputs.nix-alien.overlays.default
      ];

      defaultSystem = inputs.flake-utils.lib.system.x86_64-linux;

      # Just add systems here and it should add systems to the outputs.
      systems = with inputs.flake-utils.lib.system; [ defaultSystem ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # We're considering this as the variant since we'll export the custom
      # library as `lib` in the output attribute.
      lib' = nixpkgs.lib.extend (final: prev:
        import ./lib { lib = prev; }
        // import ./lib/private.nix { lib = final; });

      extraArgs = {
        inherit (inputs) nix-colors dotfiles;
        inherit inputs self;

        # This is a variable that is used to check whether the module is
        # exported or not. Useful for configuring parts of the configuration
        # that is otherwise that cannot be exported for others' use.
        #
        # "Fds" stands for foo-dogsquared just because. :p
        _isInsideFds = true;
      };

      mkHost = { system ? defaultSystem, extraModules ? [ ] }:
        (lib'.makeOverridable inputs.nixpkgs.lib.nixosSystem) {
          # The system of the NixOS system.
          inherit system;
          lib = lib';
          specialArgs = extraArgs;
          modules =
            # Append with our custom NixOS modules from the modules folder.
            (lib'.modulesToList (lib'.filesToAttr ./modules/nixos))

            # Our own modules.
            ++ extraModules;
        };

      hostSharedConfig = { config, lib, pkgs, ... }: {
        # Some defaults for evaluating modules.
        _module.check = true;

        # Only use imports as minimally as possible with the absolute
        # requirements of a host. On second thought, only on flakes with
        # optional NixOS modules.
        imports = [
          inputs.home-manager.nixosModules.home-manager
          inputs.nix-ld.nixosModules.nix-ld
          inputs.nur.nixosModules.nur
          inputs.sops-nix.nixosModules.sops
          inputs.guix-overlay.nixosModules.guix
        ];

        # BOOOOOOOOOOOOO! Somebody give me a tomato!
        services.xserver.excludePackages = with pkgs; [ xterm ];

        # I want to capture the usual flakes to its exact version so we're
        # making them available to our system. This will also prevent the
        # annoying downloads since it always get the latest revision.
        nix.registry =
          lib.mapAttrs'
            (name: flake:
              let
                name' = if (name == "self") then "config" else name;
              in
              lib.nameValuePair name' { inherit flake; })
            inputs;

        # Set several paths for the traditional channels.
        nix.nixPath =
          lib.mapAttrsToList
            (name: source:
              let
                name' = if (name == "self") then "config" else name;
              in
              "${name'}=${source}")
            inputs
          ++ [
            "/nix/var/nix/profiles/per-user/root/channels"
          ];

        nix.settings = {
          # Set several binary caches.
          substituters = [
            "https://nix-community.cachix.org"
            "https://foo-dogsquared.cachix.org"
            "https://helix.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "foo-dogsquared.cachix.org-1:/2fmqn/gLGvCs5EDeQmqwtus02TUmGy0ZlAEXqRE70E="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
          ];

          # Sane config for the package manager.
          # TODO: Remove this after nix-command and flakes has been considered stable.
          #
          # Since we're using flakes to make this possible, we need it. Plus, the
          # UX of Nix CLI is becoming closer to Guix's which is a nice bonus.
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = lib.mkDefault true;
        };

        nixpkgs.config.permittedInsecurePackages =
          [ "python3.10-django-3.1.14" "qtwebkit-5.212.0-alpha4" ];

        # Stallman-senpai will be disappointed.
        nixpkgs.config.allowUnfree = true;

        # Extend nixpkgs with our overlays except for the NixOS-focused modules
        # here.
        nixpkgs.overlays = overlays;

        # Please clean your temporary crap.
        boot.cleanTmpDir = lib.mkDefault true;

        # We live in a Unicode world and dominantly English in technical fields so we'll
        # have to go with it.
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

        # The global configuration for the home-manager module.
        home-manager.useUserPackages = lib.mkDefault true;
        home-manager.useGlobalPkgs = lib.mkDefault true;
        home-manager.sharedModules =
          lib.modulesToList (lib.filesToAttr ./modules/home-manager)
          ++ [ userSharedConfig ];
        home-manager.extraSpecialArgs = extraArgs;

        # Enabling some things for sops.
        programs.gnupg.agent = lib.mkDefault {
          enable = true;
          enableSSHSupport = true;
        };
        services.sshd.enable = lib.mkDefault true;
        services.openssh.enable = lib.mkDefault true;

        # We're setting Guix service package with the flake-provided package.
        # This is to prevent problems setting with overlays as much as I like
        # using them.
        services.guix.package = inputs.guix-overlay.packages.${config.nixpkgs.system}.guix;
      };

      mkUser = { system ? defaultSystem, extraModules ? [ ] }:
        inputs.home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = extraArgs;
          lib = lib';
          pkgs = import nixpkgs { inherit system overlays; };
          modules =
            # Importing our custom home-manager modules.
            (lib'.modulesToList (lib'.filesToAttr ./modules/home-manager))

            # Plus our own.
            ++ extraModules;
        };

      # The default config for our home-manager configurations. This is also to
      # be used for sharing modules among home-manager users from NixOS
      # configurations with `nixpkgs.useGlobalPkgs` set to `true` so avoid
      # setting nixpkgs-related options here.
      userSharedConfig = { pkgs, config, ... }: {
        # Hardcoding this is not really great especially if you consider using
        # other locales but its default values are already hardcoded so what
        # the hell. For other users, they would have to do set these manually.
        xdg.userDirs =
          let
            # The home directory-related options should be already taken care
            # of at this point. It is an ABSOLUTE MUST that it is set properly
            # since other parts of the home-manager config relies on it being
            # set properly.
            #
            # Here are some of the common cases for setting the home directory
            # options.
            #
            # * For exporting home-manager configurations, this is done in this
            #   flake definition.
            # * For NixOS configs, this is done automatically by the
            #   home-manager NixOS module.
            # * Otherwise, you'll have to manually set them.
            appendToHomeDir = path: "${config.home.homeDirectory}/${path}";
          in
          {
            desktop = appendToHomeDir "Desktop";
            documents = appendToHomeDir "Documents";
            download = appendToHomeDir "Downloads";
            music = appendToHomeDir "Music";
            pictures = appendToHomeDir "Pictures";
            publicShare = appendToHomeDir "Public";
            templates = appendToHomeDir "Templates";
            videos = appendToHomeDir "Videos";
          };

        programs.home-manager.enable = true;

        manual = {
          html.enable = true;
          json.enable = true;
          manpages.enable = true;
        };
      };

      # A wrapper around the nixos-generators `nixosGenerate` function.
      mkImage = { system ? null, pkgs ? null, extraModules ? [ ], extraArgs ? { }, format ? "iso" }:
        inputs.nixos-generators.nixosGenerate {
          inherit pkgs system format;
          lib = lib';
          specialArgs = extraArgs;
          modules =
            # Import all of the NixOS modules.
            (lib'.modulesToList (lib'.filesToAttr ./modules/nixos))

            # Our own modules.
            ++ extraModules;
        };

      # A set of images with their metadata that is usually built for usual
      # purposes. The format used here is whatever formats nixos-generators
      # support.
      images = {
        bootstrap.format = "install-iso";
        graphical-installer.format = "install-iso";
        plover.format = "gce";
        void.format = "vm";
      };
    in
    {
      # Exposes only my library with the custom functions to make it easier to
      # include in other flakes for whatever reason may be.
      lib = import ./lib { lib = nixpkgs.lib; };

      # A list of NixOS configurations from the `./hosts` folder. It also has
      # some sensible default configurations.
      nixosConfigurations = lib'.mapAttrsRecursive
        (host: path:
          let
            host' = lib'.last host;
            extraModules = [
              ({ lib, ... }: {
                # We're very lax with setting the default since there's a lot
                # of modules that may set this especially with image media
                # modules.
                networking.hostName = lib.mkOverride 2000 host';
              })
              (lib'.optionalAttrs (lib'.hasAttr host' images)
                (let
                  imageFormat = images.${host'}.format;
                  in inputs.nixos-generators.nixosModules.${imageFormat}))
              hostSharedConfig
              path
            ];
          in
          mkHost { inherit extraModules; })
        (lib'.filesToAttr ./hosts);

      # We're going to make our custom modules available for our flake. Whether
      # or not this is a good thing is debatable, I just want to test it.
      nixosModules = lib'.importModules (lib'.filesToAttr ./modules/nixos);

      # I can now install home-manager users in non-NixOS systems.
      # NICE!
      homeManagerConfigurations = lib'.mapAttrs
        (_: path:
          let
            extraModules = [
              ({ pkgs, config, ... }: {
                # To be able to use the most of our config as possible, we want
                # both to use the same overlays.
                nixpkgs.overlays = overlays;

                # Stallman-senpai will be disappointed. :/
                nixpkgs.config.allowUnfree = true;

                # Setting the homely options.
                home.username = builtins.baseNameOf path;
                home.homeDirectory = "/home/${config.home.username}";
              })
              userSharedConfig
              path
            ];
          in
          mkUser { inherit extraModules; })
        (lib'.filesToAttr ./users/home-manager);

      # Extending home-manager with my custom modules, if anyone cares.
      homeManagerModules =
        lib'.importModules (lib'.filesToAttr ./modules/home-manager);

      # In case somebody wants to use my stuff to be included in nixpkgs.
      overlays.default = final: prev: import ./pkgs { pkgs = prev; };

      # My custom packages, available in here as well. Though, I mainly support
      # "x86_64-linux". I just want to try out supporting other systems.
      packages = forAllSystems (system: let
        pkgs = import nixpkgs { inherit system overlays; };
      in
        inputs.flake-utils.lib.flattenTree (import ./pkgs { inherit pkgs; })
        // lib'.mapAttrs'
            (name: value:
              lib'.nameValuePair "${name}-${value.format}" (mkImage {
                inherit system pkgs extraArgs;
                inherit (value) format;
                extraModules = [
                  ({ lib, ... }: {
                    networking.hostName = lib.mkOverride 2000 name;
                  })
                  hostSharedConfig
                  ./hosts/${name}
                ];
              }))
            images);

      # My several development shells for usual type of projects. This is much
      # more preferable than installing all of the packages at the system
      # configuration (or even home environment).
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in {
          default = import ./shell.nix { inherit pkgs; };
        } // (import ./shells { inherit pkgs; }));

      # Cookiecutter templates for your mama.
      templates = {
        default = self.templates.basic-devshell;
        basic-devshell = {
          path = ./templates/basic-devshell;
          description = "Basic development shell template";
        };
        basic-overlay-flake = {
          path = ./templates/basic-overlay-flake;
          description = "Basic overlay as a flake";
        };
      };

      # No amount of formatters will make this codebase nicer but it sure does
      # feel like it does.
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.treefmt);

      # nixops-lite (that is much more powerful than nixops itself)... in
      # here!?! We got it all, son!
      #
      # Take note for automatically imported nodes, various options should be
      # overridden in the deploy utility considering that most have only
      # certain values and likely not work if run with the intended value.
      #
      # Also, don't forget to always clean your shell history when overriding
      # sensitive info such as the hostname and such. A helpful tip would be
      # ignoring the shell entry by simply prefixing it with a space which most
      # command-line shells have support for (e.g., Bash, zsh, fish).
      deploy.nodes = let
        nixosConfigurations = lib'.mapAttrs'
          (name: value:
            lib'.nameValuePair "nixos-${name}" {
              hostname = name;
              fastConnection = true;
              profiles.system = {
                sshUser = "admin";
                user = "root";
                path = inputs.deploy.lib.${defaultSystem}.activate.nixos value;
              };
            })
          self.nixosConfigurations;
        homeManagerConfigurations = lib'.mapAttrs'
          (name: value:
            lib'.nameValuePair "home-manager-${name}" {
              hostname = name;
              fastConnection = true;
              profiles.home = {
                sshUser = name;
                path = inputs.deploy.lib.${defaultSystem}.activate.home-manager value;
              };
            })
          self.homeManagerConfigurations;
      in nixosConfigurations // homeManagerConfigurations;

      # How to make yourself slightly saner than before. So far the main checks
      # are for deploy nodes.
      checks = lib'.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        inputs.deploy.lib;

      # I'm cut off from the rest of my setup with no Hydra instance yet but
      # I'm sure it will grow some of them as long as you didn't put it under a
      # rock.
      hydraJobs.build-packages = forAllSystems (system: self.packages.${system});
    };
}
