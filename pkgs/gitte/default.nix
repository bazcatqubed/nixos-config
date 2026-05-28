# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: LGPL-2.1-or-later

{
  stdenv,
  lib,
  fetchFromCodeberg,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  cargo,
  wrapGAppsHook4,
  libadwaita,
  openssl,
  libxml2,

  desktop-file-utils,
  appstream,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gitte";
  version = "0.5.0";

  src = fetchFromCodeberg {
    owner = "ckruse";
    repo = "Gitte";
    rev = finalAttrs.version;
    hash = "sha256-sDMkT/XfJbRyWrMTcG2bx1wo5N4ZUNupzMMb46jtlwQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config

    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    cargo
    rustc
    wrapGAppsHook4

    desktop-file-utils
    appstream
    glib
  ];

  buildInputs = [
    libadwaita
    libxml2
    openssl
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-i8NlzDWNSoPQafKfYal4PJPS+Ku4Vd1OQC4nrj3cNbU=";
  };

  meta = {
    homepage = "https://codeberg.org/ckruse/Gitte";
    description = "Graphical Git client for GNOME";
    license = lib.licenses.agpl3Plus;
  };
})
