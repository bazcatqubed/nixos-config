{ stdenv
, lib
, buildNpmPackage
, fetchFromGitHub
, meson
, ninja
, pkg-config
, gobject-introspection
, gjs
, gtk3
, libpulseaudio
}:

buildNpmPackage rec {
  pname = "ags";
  version = "1.5.5-beta";

  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "ags";
    rev = "v${version}";
    hash = "sha256-xYwB5V9jlAxftJvy40WH42vM5iSf95c5bE72NLhWVsg=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-y5kIMnZSU4IV2oCitcXFc6y7oVJxnLCzkA1lvSOrc/k=";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    gjs
  ];

  buildInputs = [
    gjs
    gtk3
    libpulseaudio
  ];

  # TODO: I have no idea how to properly make use of the binaries from
  # node_modules folder, pls fix later (or is this the most Nix-idiomatic way of
  # doing this?). :(
  preConfigure = ''
    addToSearchPath PATH $PWD/node_modules/.bin
  '';

  meta = with lib; {
    homepage = "https://github.com/Aylur/ags";
    description = "A EWW-inspired widget system as a GJS library";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    platforms = platforms.linux;
  };
}
