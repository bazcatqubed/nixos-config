# SPDX-FileCopyrightText: 2022-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  fetchgit,
  python3,
  mopidy,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "mopidy-funkwhale";
  version = "1.1.0";
  format = "pyproject";

  src = fetchgit {
    url = "https://dev.funkwhale.audio/funkwhale/mopidy.git";
    rev = "v${version}";
    sha256 = "sha256-vSjUWXUFGGAlFLYSdODUxd+SnK+HBCLOAhEySQBXk4A=";
  };

  postPatch = ''
    sed -i 's/vext/pykka/' setup.cfg
  '';

  propagatedBuildInputs =
    with python3.pkgs;
    [
      pykka
      requests
      requests-oauthlib
      pygobject3
    ]
    ++ [ mopidy ];

  checkInputs = with python3.pkgs; [
    pytest
    pytest-cov
    pytest-mock
    requests-mock
    factory-boy
  ];

  meta = with lib; {
    description = "Mopidy extension for streaming music from a Funkwhale server";
    homepage = "https://funkwhale.audio";
    license = licenses.gpl3Plus;
  };
}
