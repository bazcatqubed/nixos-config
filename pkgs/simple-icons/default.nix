# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simple-icons";
  version = "16.30.0";

  src = fetchFromGitHub {
    owner = "simple-icons";
    repo = "simple-icons";
    rev = finalAttrs.version;
    hash = "sha256-YD4K86DCCRzLFP6ahJV3vzbVVFYiNNpobmab3Ontx5w=";
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/share/simple-icons
    cp -t $out/share/simple-icons -r ./data ./icons
    runHook postBuild
  '';

  doCheck = false;
  dontFixup = true;

  meta = with lib; {
    description = "Set of brand icons";
    homepage = "https://simpleicons.org/";
    license = licenses.cc0;
  };
})
