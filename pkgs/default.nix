{ pkgs ? import <nixpkgs> { }, overrides ? (self: super: { }) }:

with pkgs;

let
  packages = self:
    let callPackage = newScope self;
    in {
      adwcustomizer = callPackage ./adwcustomizer { };
      artem = callPackage ./artem.nix { };
      auto-editor = callPackage ./auto-editor.nix { };
      awesome-cli = callPackage ./awesome-cli { };
      cursedgl = callPackage ./cursedgl { };
      clidle = callPackage ./clidle.nix { };
      domterm = callPackage ./domterm { };
      freerct = callPackage ./freerct.nix { };
      distant = callPackage ./distant.nix { };
      devdocs-desktop = callPackage ./devdocs-desktop.nix { };
      doggo = callPackage ./doggo.nix { };
      emulsion-palette = callPackage ./emulsion-palette.nix { };
      gol-c = callPackage ./gol-c.nix { };
      gnome-frog = callPackage ./frog { };
      gnome-search-provider-recoll =
        callPackage ./gnome-search-provider-recoll.nix { };
      gnome-extension-manager = callPackage ./gnome-extension-manager.nix { };
      gnome-shell-extension-fly-pie =
        callPackage ./gnome-shell-extension-fly-pie.nix { };
      gnome-shell-extension-pop-shell =
        callPackage ./gnome-shell-extension-pop-shell.nix { };
      guile-config = callPackage ./guile-config.nix { };
      guile-hall = callPackage ./guile-hall.nix { };
      hoppscotch-cli = callPackage ./hoppscotch-cli.nix { };
      hush-shell = callPackage ./hush-shell.nix { };
      ictree = callPackage ./ictree.nix { };
      libcs50 = callPackage ./libcs50.nix { };
      license-cli = callPackage ./license-cli { };
      moac = callPackage ./moac.nix { };
      mopidy-beets = callPackage ./mopidy-beets.nix { };
      mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
      mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
      nautilus-annotations = callPackage ./nautilus-annotations { };
      neuwaita-icon-theme = callPackage ./neuwaita-icon-theme { };
      pop-launcher = callPackage ./pop-launcher.nix { };
      pop-launcher-plugin-duckduckgo-bangs =
        callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
      text-engine = callPackage ./text-engine.nix { };
      tic-80 = callPackage ./tic-80 { };
      thokr = callPackage ./thokr.nix { };
      segno = callPackage ./segno.nix { };
      vpaint = libsForQt5.callPackage ./vpaint.nix { };
      watc = callPackage ./watc { };
      wayback = callPackage ./wayback.nix { };
      wzmach = callPackage ./wzmach { };
      ymuse = callPackage ./ymuse { };
    };
in
lib.fix (lib.extends overrides packages)
