# I only use Emacs for org-roam (seriously... I only learned Emacs for
# that). Take note this profile doesn't setup Emacs-as-a-development-tool
# thing, rather Emacs-as-a-note-taking tool thing with the complete
# package.
{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.doom-emacs;

  doomEmacsInstallation = "${config.xdg.configHome}/emacs";
in {
  options.users.foo-dogsquared.programs.doom-emacs.enable =
    lib.mkEnableOption "foo-dogsquared's Doom Emacs configuration";

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
      extraPackages = epkgs:
        with epkgs; [
          org-noter-pdftools
          org-pdftools
          pdf-tools
          vterm
        ];
    };

    # Automatically install Doom Emacs from here.
    home.mutableFile.${doomEmacsInstallation} = {
      url = "https://github.com/doomemacs/doomemacs.git";
      type = "git";
      extraArgs = [ "--depth" "1" ];
      postScript = ''
        ${doomEmacsInstallation}/bin/doom install --no-config --no-fonts --install --force
        ${doomEmacsInstallation}/bin/doom sync
      '';
    };

    home.sessionPath = [ "${doomEmacsInstallation}/bin" ];

    # Doom Emacs dependencies for the usual modules.
    home.packages = with pkgs; [
      # :ui doom
      nerd-fonts.symbols-only

      # :checkers spell
      aspell
      aspellDicts.en
      aspellDicts.en-computers

      # :tools lookup
      wordnet

      # :lang common-lisp
      guile_3_0

      # :lang org +roam2
      sqlite
    ];

    programs.texlive = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.texliveMedium;
    };

    programs.python = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.python313;
      modules = ps: with ps; [ jupyter ];
    };

    # Enable Emacs server for them quicknotes.
    services.emacs = {
      enable = true;
      socketActivation.enable = true;
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
