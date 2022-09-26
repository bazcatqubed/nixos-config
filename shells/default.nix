{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  flatpak = callPackage ./flatpak.nix { };
  gnu = callPackage ./gnu.nix { };
  gnome = callPackage ./gnome.nix { };
  nix = callPackage ./nix.nix { };
  guile = callPackage ./guile.nix { };
  guile3 = callPackage ./guile.nix { guile = guile_3_0; };
  gtk3 = callPackage ./gtk.nix { gtk = gtk3; libportal-gtk = libportal-gtk3; };
  gtk4 = callPackage ./gtk.nix { gtk = gtk4; wrapGAppsHook = wrapGAppsHook4; libportal-gtk = libportal-gtk4; };
  hugo = callPackage ./hugo.nix { };
  lua_5_2 = callPackage ./lua.nix { lua = lua52Packages.lua; };
  lua_5_3 = callPackage ./lua.nix { lua = lua53Packages.lua; };
  rust = callPackage ./rust.nix { };
  tic-80 = callPackage ./tic-80.nix { };
}
