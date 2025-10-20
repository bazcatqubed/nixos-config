{ pkgs, lib, self }:

rec {
  /* Given a Blender package and its addons to be wrapped, create a derivation
     containing all of the addons properly placed as a system resource folder.
  */
  wrapBlenderAddons = { blenderPackage ? pkgs.blender, addons }:
    let blenderVersion = lib.versions.majorMinor blenderPackage.version;
    in pkgs.runCommand "blender-system-resources" {
      passAsFile = [ "paths" ];
      paths = addons ++ [ blenderPackage ];
      nativeBuildInputs = with pkgs; [ outils ];
    } ''
      mkdir -p $out
      for i in $(cat $pathsPath); do
        resourcesPath="$i/share/blender"
        if [ -d $i/share/blender/${blenderVersion} ]; then
          resourcesPath="$i/share/blender/${blenderVersion}";
        fi
        cp -r $resourcesPath $out
      done
    '';

  makeBlenderWrapper =
    module@{ blenderPackage ? pkgs.blender, blenderArgs ? [ ], addons ? [ ], ... }:
    let blenderAddons = wrapBlenderAddons { inherit blenderPackage addons; };
    in lib.mkMerge [
      {
        arg0 = lib.getExe' blenderPackage "blender";
        prependArgs = lib.mkBefore blenderArgs;
      }

      (lib.mkIf (builtins.length addons > 0) {
        env.BLENDER_SYSTEM_RESOURCES.value = blenderAddons;
      })

      (lib.removeAttrs module [ "blenderPackage" "blenderArgs" "addons" ])
    ];

  # Create a configuration module for quickly wrapping with Boxxy.
  makeBoxxyWrapper =
    module@{ boxxyArgs, wraparound, wraparoundArgs ? [ ], ... }:
    lib.mkMerge [
      {
        arg0 = lib.getExe' pkgs.boxxy "boxxy";
        prependArgs =
          lib.mkBefore (boxxyArgs ++ [ "--" wraparound ] ++ wraparoundArgs);
      }

      (builtins.removeAttrs module [
        "boxxyArgs"
        "wraparound"
        "wraparoundArgs"
      ])
    ];

  /* Given the path to the source code, the attribute path, and the executable
     name, return the store path to one of its executables.
  */
  getNixglExecutable =
    { src, variant ? [ "auto" "nixGLDefault" ], nixglProgram ? "nixGL" }:
    let
      nixgl = import src { inherit pkgs; };
      nixglPkg = lib.getAttrFromPath variant nixgl;
    in lib.getExe' nixglPkg nixglProgram;

  # Create a configuration module for quickly wrapping with NixGL.
  makeNixglWrapper = { nixglSrc, nixglArgs, nixglVariant, nixglExecutable
    , wraparound, wraparoundArgs ? [ ], ... }@module:
    lib.mkMerge [
      {
        arg0 = getNixglExecutable nixglSrc nixglVariant nixglExecutable;
        prependArgs =
          lib.mkBefore (nixglArgs ++ [ "--" wraparound ] ++ wraparoundArgs);
      }

      (builtins.removeAttrs module [
        "nixglArgs"
        "nixglVariant"
        "nixglExecutable"
        "wraparound"
        "wraparoundArgs"
      ])
    ];

  wrapChromiumWebApp =
    { name, baseURL ? null, url ? "https://${baseURL}", chromiumPackage ? pkgs.chromium, imageHash ? null, imageSize ? 256, imageBuildFlags ? [ ], ... }@module:
    let
      className = "${chromiumPackage.pname}-${name}";
    in
    lib.mkMerge [
      {
        arg0 = lib.getExe chromiumPackage;

        # If you want to explore what them flags are doing, you can see them in
        # their codesearch at:
        # https://source.chromium.org/chromium/chromium/ (chrome_switches.cc file)
        #
        # For now, the user directory is not dynamically set since the default
        # wrapper arguments is placed in a binary-based wrapper which doesn't
        # accept shell-escaped arguments well.
        #
        # Also, we're keeping a minimal list for now to consider the other
        # Chromium-based browsers such as Brave, Microsoft Edge, and Google
        # Chrome.
        appendArgs = [
          "--app=${url}"
          "--no-first-run"
          "--class=${className}"
        ];

        xdg.desktopEntry = {
          enable = true;
          settings = {
            terminal = false;
            startupWMClass = lib.mkDefault (if (baseURL != null) then "chrome-${baseURL}__-Default" else className);
          };
        };
      }

      (lib.mkIf (imageHash != null) {
        xdg.desktopEntry.settings.icon =
          let
            iconDrv = self.fetchers.fetchWebsiteIcon {
              inherit url;
              hash = imageHash;
              size = imageSize;
              buildFlags = imageBuildFlags;
            };
          in
          lib.mkDefault iconDrv;
      })

      (builtins.removeAttrs module [
        "chromiumPackage"
        "baseURL"
        "url"
        "imageHash"
        "imageBuildFlags"
        "imageSize"
        "name"
      ])
    ];

  commonChromiumFlags = [
    "--disable-sync"
    "--no-service-autorun"
  ];

  # List of Chromium flags to be as least intrusive as possible. This should be
  # used sparingly though if you're sure that the web application doesn't make
  # full use of Chromium's capabilities.
  commonMinimalChromiumFlags = [
    "--disable-background-networking"
    "--disable-default-apps"
    "--dns-prefetch-disable"
    "--disable-component-extensions-with-background-pages"
    "--disable-backgrounding-occluded-windows"
  ];

  systemdSubenvModule = { config, ... }: {
    options.nixEnv = {
      pathsToLink = lib.mkOption {
        type = with lib.types; listOf nonEmptyStr;
        description = ''
          List of directories per-given package in `paths` to be included as
          part of the Nix environment.

          ::: {.note}
          This is given as part of `buildEnv` builder of the Nix environment
          for the systemd unit.
          :::
        '';
        default = [ "/" ];
        example = [
          "/bin"
          "/share/wayland-sessions"
          "/share/gnome-session"
          "/share/systemd"
        ];
      };

      paths = lib.mkOption {
        type = with lib.types; listOf package;
        description = ''
          Packages to be included in the Nix profile.
        '';
        default = [ ];
        example = lib.literalExpression ''
          with pkgs; [
            hello
            coreutils
            gcc

            moreutils
            man-pages-posix
          ];
        '';
      };

      extraOutputsToInstall = lib.mkOption {
        type = with lib.types; nullOr (listOf nonEmptyStr);
        description = ''
          A list of extra derivation outputs to install to the Nix environment.
        '';
        default = null;
        example = [ "man" ];
      };

      profileRelativeEnvVars = lib.mkOption {
        type = with lib.types; attrsOf (listOf string);
        description = ''
          A set of environment variables to be set relative to the Nix profile.
        '';
        example = {
          MANPATH = [
            "/man"
            "/share/man"
          ];

          PATH = [
            "/bin"
          ];
        };
      };
    };

    config.environment = lib.mkIf (config.nixEnv.paths != [ ]) (
      let
        nixEnv = pkgs.buildEnv {
          name = "systemd-unit-${self.systemd.escapeSystemdPath config.name}-nix-profile";
          inherit (config.nixEnv) extraOutputsToInstall paths pathsToLink;
        };

        mkEnvVar = _: paths:
          lib.map (suffix: "${nixEnv}${suffix}") paths;
      in
        lib.mapAttrs mkEnvVar config.nixEnv.profileRelativeEnvVars
    );
  };

  mkGnomeSessionTargetUnit = config: workflowName: requiredComponents:
    let
      sessionConfig = config.programs.gnome-session.sessions.${workflowName};
      getId = lib.foldlAttrs (acc: _: v: acc ++ [ "${v.id}.target" ]) [ ];
    in {
      requires = getId (lib.filterAttrs (n: _: lib.elem n requiredComponents) sessionConfig.components);
      wants = getId (lib.attrsets.removeAttrs sessionConfig.components requiredComponents);
    };
}
