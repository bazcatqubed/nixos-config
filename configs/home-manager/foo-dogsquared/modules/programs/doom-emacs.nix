# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# I only use Emacs for org-roam (seriously... I only learned Emacs for
# that). Take note this profile doesn't setup Emacs-as-a-development-tool
# thing, rather Emacs-as-a-note-taking tool thing with the complete
# package.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.doom-emacs;

  doomEmacsInstallation = "${config.xdg.configHome}/emacs";

  emacsPackages = pkgs.emacsPackagesFor cfg.package;
in
{
  options.users.foo-dogsquared.programs.doom-emacs = {
    enable = lib.mkEnableOption "foo-dogsquared's Doom Emacs configuration";

    package = lib.mkPackageOption pkgs "emacs" { };

    extraModules = lib.mkOption {
      description = ''
        Extra Emacs packages to be added within the custom Emacs package in the
        Doom Emacs installation.
      '';
      type = with lib.types; functionTo (listOf package);
      default = self: [ ];
      defaultText = "epkgs: []";
      example = lib.literalExpression /* nix */ ''
        epkgs: with epkgs; [
          org-noter-pdftools
          org-pdftools
          pdf-tools
          vterm
        ]
      '';
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression /* nix */ ''
        with pkgs; [
          sqlite3
          aspell
          aspellDicts.en
          aspellDicts.en-computers
          wordnet
          guile_3_0
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wrapper-manager.packages.doom-emacs =
      let
        emacsPkg = emacsPackages.withPackages cfg.extraModules;
      in
      {
        basePackages = lib.singleton emacsPkg;

        # Doom Emacs dependencies for the usual modules.
        subenvironments.doom = {
          paths = cfg.extraPackages;
          profileRelativeEnvVars = {
            PATH = [ "/bin" ];
            XDG_DATA_DIRS = [ "/share" ];
          };
        };
      };

    # Automatically install Doom Emacs from here.
    home.mutableFile.${doomEmacsInstallation} = {
      url = "https://github.com/doomemacs/doomemacs.git";
      type = "git";
      extraArgs = [
        "--depth"
        "1"
      ];
      postScript = ''
        ${doomEmacsInstallation}/bin/doom install --no-config --no-fonts --install --force
        ${doomEmacsInstallation}/bin/doom sync
      '';
    };

    home.sessionPath = [ "${doomEmacsInstallation}/bin" ];

    programs.texlive = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.texliveMedium;
    };

    # Add org-protocol support.
    xdg.desktopEntries.org-protocol = {
      name = "org-protocol";
      exec = "emacsclient -- %u";
      mimeType = [ "x-scheme-handler/org-protocol" ];
      terminal = false;
      comment = "Intercept calls from emacsclient to trigger custom actions";
      noDisplay = true;
    };

    xdg.mimeApps.defaultApplications = {
      "application/json" = [ "emacs.desktop" ];
      "text/org" = [ "emacs.desktop" ];
      "text/plain" = [ "emacs.desktop" ];
      "x-scheme-handler/org-protocol" = [ "org-protocol.desktop" ];
    };
  };
}
