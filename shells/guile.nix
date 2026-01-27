# SPDX-FileCopyrightText: 2022-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  mkShell,
  lib,
  gcc,
  gettext,
  pkg-config,
  texinfo,
  guile,
  guile-hall,
}:

let
  guileVersion = lib.versions.majorMinor guile.version;
in
mkShell {
  inherit guileVersion;
  packages = [
    gettext
    guile
    guile-hall
    pkg-config
    texinfo
  ];

  inputsFrom = [
    gcc
    guile
  ];
}
