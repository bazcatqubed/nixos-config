# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  glib,
  gtk4,
  libadwaita,
  cargo,
  rustc,
  desktop-file-utils,
  appstream-glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bobby";
  version = "49.0.4";

  src = fetchFromGitHub {
    owner = "hbons";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-xBPmIJc+THpoxwoHBTbCVTTn7BeNgMJ5iPGs1b//krU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    rustPlatform.cargoSetupHook
    desktop-file-utils
    appstream-glib
    cargo
    rustc
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-I8wnajVtI5FGJ0BVPGd+65aZ9TYRVDrbabqETt+QP2o=";
  };

  meta = with lib; {
    homepage = "https://planetpeanut.studio/bobby";
    description = "SQLite database browser";
    license = licenses.gpl3Plus;
  };
})
