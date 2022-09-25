{
  description = "foo-dogsquared's NixOS config as a flake";

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

    # We're using this library for other functions, mainly testing.
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

    # We're getting more unstable there should be a black hole at my home right now.
    # Also, we're seem to be collecting text editors like it is Pokemon.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.flake-utils.follows = "flake-utils";

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";

    # Guix in NixOS?!
    guix-overlay.url = "github:foo-dogsquared/nix-overlay-guix";
    guix-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # The more recommended Rust overlay so I'm going with it.
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";

    # Generating an entire flavored themes with Nix?
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      # The order here is important(?).
      overlays = [
        # Put my custom packages to be available.
        self.overlays.default

        # Putting a list for inputs without overlays.
        (final: prev: {
          helix-unstable = inputs.helix-editor.packages.${builtins.currentSystem}.default;
        })

        # Neovim nightly!
        inputs.neovim-nightly-overlay.overlay

        # Emacs unstable version!
        inputs.emacs-overlay.overlay

        # Rust overlay for them ease of setting up Rust toolchains.
        inputs.rust-overlay.overlays.default

        # Access to NUR.
        inputs.nur.overlay
      ];

      defaultSystem = inputs.flake-utils.lib.system.x86_64-linux;
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

      # The default configuration for our NixOS systems.
      hostDefaultConfig = { lib, pkgs, system, ... }: {
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

        # Bleeding edge, baybee!
        nix.package = lib.mkDefault pkgs.nixUnstable;

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
          [ "python3.10-django-3.1.14" ];

        # Stallman-senpai will be disappointed.
        nixpkgs.config.allowUnfree = lib.mkDefault true;

        # Extend nixpkgs with our overlays except for the NixOS-focused modules
        # here.
        nixpkgs.overlays = overlays
          ++ [ inputs.nix-alien.overlay inputs.guix-overlay.overlays.default ];

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
          ++ [ userDefaultConfig ];
        home-manager.extraSpecialArgs = extraArgs;

        # Enabling some things for sops.
        programs.gnupg.agent = lib.mkDefault {
          enable = true;
          enableSSHSupport = true;
        };
        services.sshd.enable = lib.mkDefault true;
        services.openssh.enable = lib.mkDefault true;
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
      userDefaultConfig = { pkgs, config, ... }: {
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
            # Here are some of the common cases for setting the home directory options.
            #
            # * For exporting home-manager configurations, this is done in this flake definition.
            # * For NixOS configs, this is set in `mapHomeManagerUser` from the private library.
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
            extraModules = [
              ({ lib, ... }: {
                networking.hostName = lib.mkDefault (builtins.baseNameOf path);
              })
              hostDefaultConfig
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
                # To be able to use the most of our config as possible, we want both to
                # use the same overlays.
                nixpkgs.overlays = overlays;

                # Stallman-senpai will be disappointed. :(
                nixpkgs.config.allowUnfree = true;

                # Setting the homely options.
                home.username = builtins.baseNameOf path;
                home.homeDirectory = "/home/${config.home.username}";
              })
              userDefaultConfig
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
      packages = forAllSystems (system:
        inputs.flake-utils.lib.flattenTree (import ./pkgs {
          pkgs = import nixpkgs { inherit system overlays; };
        }));

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
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
