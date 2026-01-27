# SPDX-FileCopyrightText: 2022-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenv,
  lib,
  python3Packages,
  ...
}:

with python3Packages;
buildPythonPackage rec {
  pname = "aiohttp-utils";
  version = "3.2.1";
  format = "pyproject";

  src = fetchPypi {
    inherit version;
    pname = "aiohttp-utils";
    sha256 = "sha256-UJWcQ68aXvgwvHrWLB6NgFlGpB51VhFpSHvPuJq1IDw=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    aiohttp
    gunicorn
    python-mimeparse
  ];

  meta = with lib; {
    homepage = "https://github.com/sloria/aiohttp-utils";
    description = "Provides utilities for building aiohttp applications";
    license = licenses.mit;
  };
}
