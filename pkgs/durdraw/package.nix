# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "durdraw";
  version = "0.29.0";
  pyproject = true;

  build-system = with python3Packages; [ setuptools ];

  src = fetchFromGitHub {
    owner = "cmang";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-a+4DGWBD5XLaNAfTN/fmI/gALe76SCoWrnjyglNhVPY=";
  };

  meta = with lib; {
    description = "ASCII and ANSI art editor";
    homepage = "http://durdraw.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
})
