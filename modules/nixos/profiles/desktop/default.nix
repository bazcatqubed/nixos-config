# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# A common profile for desktop systems. Most of the configurations featured
# here should be enough in common to the typical desktop setups found on
# non-NixOS systems.
{
  imports = [
    ./fonts.nix
    ./audio.nix
    ./hardware.nix
  ];
}
