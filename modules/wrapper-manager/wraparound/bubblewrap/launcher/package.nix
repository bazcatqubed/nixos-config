# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wrapper-manager-bubblewrap-launcher";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = {
    description = "wrapper-manager specialized launcher for Bubblewrap environments";
    license = lib.licenses.mit;
    mainProgram = finalAttrs.pname;
  };
})
