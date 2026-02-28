# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  fetchFromCodeberg,
  qt6,
  pkg-config,
  cmake,
  ninja,
  curl,
  mupdf,
  djvulibre,
  texlivePackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lektra";
  version = "0.6.4";

  src = fetchFromCodeberg {
    owner = finalAttrs.pname;
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-MqjCmG8lp7Q+A9vCJbVenwiGbnSGPuzL8uKKkpKOHrY=";
  };

  patches = [
    ./patches/0001-Fix-CMakeLists-for-mupdf-library.patch
  ];

  strictDeps = true;
  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    curl
    djvulibre
    mupdf
    texlivePackages.synctex
    qt6.qtbase
  ];

  meta = {
    homepage = "https://codeberg.org/lektra/lektra";
    description = "PDF reader that prioritizes screen space and control";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
})
