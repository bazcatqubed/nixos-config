# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  py-slvs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blender-cad-sketcher";
  version = "unstable-2026-03-22";

  src = fetchFromGitHub {
    owner = "hlorus";
    repo = "CAD_Sketcher";
    rev = "c398c2dd394e4b0eabd0e74eba0036b23f351c28";
    hash = "sha256-5Vy7vs3tH3LXreqHd90D3n5kP9X/f2Wa8d8Dy4D9YoQ=";
  };

  propagatedNativeBuildInputs = [ py-slvs ];
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
