# SPDX-FileCopyrightText: 2026 Gabriel Arazas <__personal__@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  fetchfossil,
  rustPlatform,
  makeBinaryWrapper,
  makeDesktopItem,
  pkg-config,
  wayland,
  alsa-lib,
  dbus,
  jack2,

  libGL,
  libX11,
  libXi,
  libxkbcommon,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "osctet";
  version = "unstable-2026-10-13";

  src = fetchfossil {
    url = "https://jangle.dev/fossil/osctet";
    rev = "9fa41ac37291f976";
    hash = "sha256-y09EFK14pXUD44cQLs6UsuUrDb/eCauX4koWdsXidq8=";
  };

  cargoHash = "sha256-WRLjTarUbbk+GKO5Lv/mzDY6YuZ+7ijPKL+x9xEZ1mY=";

  desktopItems = lib.singleton (makeDesktopItem {
    name = finalAttrs.pname;
    desktopName = "osctet";
    genericName = "Music Tracker";
    exec = finalAttrs.meta.mainProgram;
  });

  nativeBuildInputs = [
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [
    alsa-lib
    dbus
    jack2
    wayland
  ];

  postFixup = ''
    wrapProgram $out/bin/osctet \
      --prefix LD_LIBRARY_PATH ":" "${
        lib.makeLibraryPath [
          libGL
          libX11
          libXi
          libxkbcommon
        ]
      }"
  '';

  meta = {
    mainProgram = finalAttrs.pname;
    homepage = "https://jangle.dev/osctet/";
    description = "Music tracker with support for unusual tunings and rhythms";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
})
