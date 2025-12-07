{ config, lib, pkgs, wrapperManagerLib, foodogsquaredLib, ... }:

let
  cfg = config.programs.chromium-web-apps;

  appSubmodule = { options, config, lib, name, ... }: {
    options = {
      baseURL = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Website URL (without the `http://` part)";
        example = "devdocs.io";
      };

      flags = lib.mkOption {
        type = with lib.types; listOf str;
        description = ''
          Additional arguments to be added to the Chromium browser.
        '';
        default = [ ];
        example = lib.literalExpression ''
          [
            "--user-data-dir=$XDG_CONFIG_HOME/''${chromiumPackage.pname}-''${name}"
          ]
        '';
      };

      startupWMClass = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default =
          if options.baseURL.isDefined then
            "chrome-${config.baseURL}__-Default"
          else
            "${cfg.package.pname}-${name}";
        description = ''
          Class name to be attached to [Desktop Entry].StartupWMClass directive
          of the desktop entry.
        '';
        example =
          lib.literalExpression "\${config.programs.chromium-web-apps.package.pname}-\${name}";
      };

      imageHash = lib.mkOption {
        type = with lib.types; nullOr str;
        description = ''
          Image hash of the default image to be fetched. This is to be set as
          the default icon fetcher which is a fixed-output derivation and set
          as the icon for the desktop entry.
        '';
        default = null;
        example = "sha512-FQWUz7CyFhpRi6iJN2LZUi8pV6AL8+74aynrTbVkMnRUNO9bo9BB6hgvOCW/DQvCl1a2SZ0iAxk2ULZKAVR0MA==";
      };

      desktopEntrySettings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = { };
        description = ''
          Additional settings to be merged into the desktop entry builder.
        '';
        example = lib.literalExpression ''
          {
            genericName = "Documentation Browser";
            comment = "One-stop shop for all of the developer documentation tools.";
          }
        '';
      };
    };
  };
in
{
  options.programs.chromium-web-apps = {
    enable = lib.mkEnableOption "configuring web apps with a Chromium-based browser";

    package = lib.mkPackageOption pkgs "google-chrome" { };

    apps = lib.mkOption {
      type = with lib.types; attrsOf (submodule appSubmodule);
      description = ''
        Set of web apps with their configurations.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          devdocs = {
            baseURL = "devdocs.io";
            imageHash = "";
            desktopEntrySettings = {
              desktopName = "DevDocs";
              genericName = "Documentation Browser";
              categories = [ "Development" ];
              comment = "One-stop shop for API documentation";
              keywords = [ "Documentation" "HTML" "CSS" "JavaScript" ];
            };
          };

          penpot = {
            baseURL = "design.penpot.app";
            imageHash = "";
            desktopEntrySettings = {
              desktopName = "Penpot";
              genericName = "Wireframing Tool";
              categories = [ "Graphics" ];
              comment = "Design and code collaboration tool";
              keywords = [ "Design" "Wireframing" "Website" ];
            };
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wrappers =
      lib.mapAttrs (n: v: let
        url = "https://${v.baseURL}";
        className = "${cfg.package.pname}-${n}";
      in  {
        arg0 = lib.getExe cfg.package;

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
        ] ++ v.flags;

        xdg.desktopEntry = {
          enable = true;
          settings = lib.mkMerge [
            v.desktopEntrySettings

            {
              inherit (v) startupWMClass;
              terminal = false;
            }

            (lib.mkIf (v.imageHash != null) (
              let
                iconDrv = foodogsquaredLib.fetchers.fetchWebsiteIcon {
                  inherit url;
                  hash = v.imageHash;
                };
              in
              {
              icon = lib.mkDefault iconDrv;
            }))
          ];
        };
      }) cfg.apps;
  };
}
