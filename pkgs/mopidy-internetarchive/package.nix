# SPDX-FileCopyrightText: 2022-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  fetchFromGitHub,
  python3Packages,
  mopidy,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-internetarchive";
  version = "3.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tkem";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-WSnT9uLEP2I1vkjv3FYPCXc4uGwlqz5c0i7c7XbmMoU=";
  };

  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
  ];

  dependencies =
    with python3Packages;
    [
      cachetools
      pykka
      requests
      uritools
    ]
    ++ [ mopidy ];

  checkInputs = with python3Packages; [
    pytest
    pytest-cov
  ];

  meta = with lib; {
    description = "Mopidy extension for listening to audio from Internet Archive";
    homepage = "https://github.com/tkem/mopidy-internetarchive";
    license = licenses.asl20;
  };
})
