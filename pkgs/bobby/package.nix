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
  version = "50.0.2";

  src = fetchFromGitHub {
    owner = "hbons";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-/N7CmzPwUdGkHIZujCGW3LvsGM6DdXrcm2kH6XlVGDA=";
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
    hash = "sha256-TT3ceAy44sfyKZ7wmH3C4nj5TyfiJlu4vBWAaGs+pGg=";
  };

  meta = with lib; {
    homepage = "https://planetpeanut.studio/bobby";
    description = "SQLite database browser";
    license = licenses.gpl3Plus;
  };
})
