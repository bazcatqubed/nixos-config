# SPDX-FileCopyrightText: 2023-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# A bunch of custom overlays. This is more suitable for larger and more
# established packages that needed extensive customization. Take note each of
# the values in the attribute set is a separate overlay function so you'll
# simply have to append them as a list (i.e., `lib.attrValues`).
{
  default = final: prev: import ../pkgs { pkgs = prev; };
  python-set-foodogsquared = import ./python-set-foodogsquared;
  ffmpeg-foodogsquared = import ./ffmpeg-foodogsquared;
  firefox-foodogsquared = import ./firefox-foodogsquared;
  blender-foodogsquared = import ./blender-foodogsquared;
  rotp-foodogsquared = import ./rotp-foodogsquared;
  thunderbird-foodogsquared = import ./thunderbird-foodogsquared;
  proton-ge-custom = import ./proton-ge-custom;
}
