# SPDX-FileCopyrightText: 2023-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  imports = [
    ./files/mutable-files.nix
    ./programs/borgmatic.nix
    ./programs/diceware.nix
    ./programs/distrobox.nix
    ./programs/epiphany.nix
    ./programs/gitu.nix
    ./programs/haskell.nix
    ./programs/kando.nix
    ./programs/newelle.nix
    ./programs/nushell.nix
    ./programs/pipewire.nix
    ./programs/pop-launcher.nix
    ./programs/pure-data.nix
    ./programs/python.nix
    ./programs/supercollider.nix
    ./programs/texlive.nix
    ./programs/typst.nix
    ./services/archivebox.nix
    ./services/bleachbit.nix
    ./services/borgbackup.nix
    ./services/borgmatic.nix
    ./services/distant.nix
    ./services/gallery-dl.nix
    ./services/gonic.nix
    ./services/ludusavi.nix
    ./services/matcha.nix
    ./services/openrefine.nix
    ./services/plover.nix
    ./services/yt-dlp.nix
  ];
}
