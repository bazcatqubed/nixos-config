# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# A common profile for desktop systems. Most of the configurations featured
# here should be enough in common to the typical desktop setups found on
# non-NixOS systems.
{ pkgs, lib, ... }:

{
  imports = [
    ./fonts.nix
    ./audio.nix
    ./hardware.nix
  ];

  # Workaround for crashing file openers with GTK-based desktop portals on QT
  # apps since nixpkgs has weird wrapping process for them.
  #
  # For more information, see NixOS/nixpkgs#149812.
  environment.sessionVariables.XDG_DATA_DIRS = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  ];
}
