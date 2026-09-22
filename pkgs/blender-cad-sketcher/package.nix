# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  fetchFromGitHub,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blender-cad-sketcher";
  version = "0.31.1";

  src = fetchFromGitHub {
    owner = "hlorus";
    repo = "CAD_Sketcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mDTAws+0tAT8qGCLr7bkqsQ8CUydvskNhatD50DZtwY=";
  };

  propagatedNativeBuildInputs = with python3Packages; [ py-slvs ];
  installPhase = ''
    runHook preInstall
    output_dir=$out/share/blender/scripts/addons/CAD_Sketcher
    mkdir -p "$output_dir" && cp --recursive $src/* "$output_dir"
    runHook postInstall
  '';

  meta = {
    homepage = "https://www.cadsketcher.com/";
    description = "Blender extension for CAD-like workflows";
    license = lib.licenses.gpl3;
  };
})
