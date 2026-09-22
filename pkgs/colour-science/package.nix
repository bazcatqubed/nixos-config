# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  opencolorio,
  python3Packages,
  optionalFeatures ? true,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "colour-science";
  version = "0.4.7";
  pyproject = true;

  src = python3Packages.fetchPypi {
    pname = "colour_science";
    inherit (finalAttrs) version;
    hash = "sha256-s0dz3E3T+bqZzKUpf6EOn1MhNNmUs6Iwjay+lw39UHk=";
  };

  propagatedBuildInputs =
    with python3Packages;
    [
      numpy
      hatchling
    ]
    ++ lib.optionals optionalFeatures [
      imageio
      matplotlib
      networkx
      pandas
      scipy
      xxhash
    ];

  propagatedNativeBuildInputs =
    let
      inherit (python3Packages) openimageio;
    in
    lib.optionals (optionalFeatures && (lib.versionAtLeast openimageio.version "3")) [
      openimageio
    ]
    ++ lib.optionals (optionalFeatures && (lib.versionAtLeast opencolorio.version "2")) [
      opencolorio
    ];

  meta = {
    description = "Comprehensive library containing algorithms and dataset for color science";
    licenses = lib.licenses.bsd3;
  };
})
