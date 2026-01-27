# SPDX-FileCopyrightText: 2022-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# Ripperootskees for the disk space.
{
  mkShell,
  texlive,
  texlab,
}:

mkShell {
  packages = [
    texlive.combined.scheme-full # RIP YOUR DISK SPACE!
    texlab # Otherwise, here's a tool to easily write your (en)grave(ing).
  ];
}
