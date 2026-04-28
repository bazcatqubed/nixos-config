# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: LGPL-2.1-or-later

{
  lib,
  stdenv,
  nix,
  lix,
  capnproto,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nix-fds-plugins";
  version = "2026-05-25";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    nix
    lix
    capnproto
  ];

  src = lib.cleanSource ../.;

  meta = {
    description = "foodogsquared's custom Nix plugins";
    license = lib.licenses.lgpl2Plus;
    platforms = nix.meta.platforms;
  };
})
