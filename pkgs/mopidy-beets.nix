{ lib, fetchFromGitHub, python3, mopidy, beets }:

python3.pkgs.buildPythonApplication rec {
  pname = "mopidy-beets";
  version = "unstable-2025-07-10";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "mopidy";
    repo = pname;
    rev = "2b1f23804dc6b03764cffcc7154104d2fb0abbff";
    hash = "sha256-V7ftl1Hvyt54I3+wTRWfSw3k5rkvYurH62hsjwJ2TCs=";
  };

  propagatedBuildInputs = with python3.pkgs;
    [ pykka requests ] ++ [ mopidy beets ];

  checkInputs = with python3.pkgs; [ pytest pytest-cov ];

  meta = with lib; {
    description = "Mopidy extension for playing music from a Beets collection";
    homepage = "https://github.com/mopidy/mopidy-beets";
    license = licenses.mit;
  };
}
