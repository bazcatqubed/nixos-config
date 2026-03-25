# SPDX-FileCopyrightText: 2023-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  imageio,
  openimageio,
}:

buildPythonPackage rec {
  pname = "blender-blendergis";
  version = "2215";
  format = "other";

  src = fetchFromGitHub {
    owner = "domlysz";
    repo = "BlenderGIS";
    rev = lib.replaceStrings [ "." ] [ "" ] version;
    hash = "sha256-Bc/ldJvpkijkiX4Eivq5MX5Ykn7p8H5AOp5ZxKmXIxg=";
  };

  propagatedBuildInputs = [ imageio ];
  buildInputs = [ openimageio ];

  passthru.blenderPluginName = "BlenderGIS";

  dontBuild = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/blender/scripts/addons/${passthru.blenderPluginName}
    cp -r . $out/share/blender/scripts/addons/${passthru.blenderPluginName}

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/domlysz/BlenderGIS/";
    description = "Blender addons for interacting with geographic data";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
  };
}
