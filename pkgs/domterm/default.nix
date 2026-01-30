# SPDX-FileCopyrightText: 2022-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  desktop-file-utils,
  pkg-config,
  libwebsockets,
  ncurses,
  openssl,
  unixtools,
  zlib,
  rustPlatform,
  perl,
  qtbase,
  qtwebchannel,
  qtwebengine,
  wrapQtAppsHook,

  withQtDocking ? false,

  withKddockwidgets ? false,
  kddockwidgets,

  withAsciidoctor ? true,
  asciidoctor,

  withDocbook ? true,
  docbook-xsl-ns,
  libxslt,
}:

stdenv.mkDerivation rec {
  pname = "domterm";
  version = "unstable-2026-01-29";

  src = fetchFromGitHub {
    owner = "PerBothner";
    repo = "DomTerm";
    rev = "d75f9062e659600f6f1c09949e3d7285fc546b33";
    hash = "sha256-S4LnOg7UmjaxFGCl0IvaJXfR1uEyM+M7oiMDYtwAJZo=";
  };

  configureFlags = [
    "--with-libwebsockets"
    "--enable-compiled-in-resources"
    "--with-qt"
  ]
  ++ lib.optional withAsciidoctor "--with-asciidoctor"
  ++ lib.optional withQtDocking "--with-qt-docking"
  ++ lib.optional withKddockwidgets "--with-kddockwidgets"
  ++ lib.optional withDocbook "--with-docbook";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapQtAppsHook
    qtbase
    qtwebchannel
    qtwebengine
  ];

  buildInputs = [
    asciidoctor
    desktop-file-utils
    ncurses
    libwebsockets
    openssl
    perl
    unixtools.xxd
    zlib
  ]
  ++ lib.optionals withKddockwidgets [ kddockwidgets ]
  ++ lib.optionals withAsciidoctor [ asciidoctor ]
  ++ lib.optionals withDocbook [
    docbook-xsl-ns
    libxslt
  ];

  meta = with lib; {
    homepage = "https://domterm.org/";
    description = "Terminal emulator based on web technologies.";
    license = licenses.bsd3;
    maintainers = with maintainers; [ foo-dogsquared ];
    broken = true;
  };
}
