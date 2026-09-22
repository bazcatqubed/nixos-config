# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  mutter,
  appstream-glib,
  glib,
  dconf,
  systemd,
  cairo,
  gsettings-desktop-schemas,
  ibus,
  libGL,
  libxcb,
  libxfixes,
  libxi,
  wayland,
  atk,
  libxkbcommon,
  lcms2,
  gnome-desktop,
  wrapGAppsHook4,
  desktop-file-utils,
  gobject-introspection,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-kiosk";
  version = "49.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-z1tu0VuoHNiX+qgVzvNfivlQqhdoxJtp08TAesMUjE8=";
  };

  nativeBuildInputs = [
    appstream-glib
    cairo
    gsettings-desktop-schemas
    gobject-introspection
    desktop-file-utils
    ibus
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    systemd
    mutter
    glib
    dconf
    libGL

    # For libmutter
    libxcb
    libxfixes
    libxi
    wayland

    # For mutter-clutter
    atk
    libxkbcommon
    lcms2

    gnome-desktop
  ];

  preInstall = ''
    schemadir="$out/share/glib-2.0/schemas"
    mkdir -p "$schemadir"
    cp "${glib.getSchemaPath mutter}/org.gnome.mutter.gschema.xml" "$schemadir"

    mkdir -p "$out/share/icons/hicolor"
  '';

  meta = {
    homepage = "https://gitlab.gnome.org/GNOME/gnome-kiosk";
    description = "GNOME Shell for single application deployments";
    license = lib.licenses.gpl2Plus;
  };
})
