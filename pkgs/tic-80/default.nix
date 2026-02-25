# SPDX-FileCopyrightText: 2021-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# Build the TIC-80 virtual computer console with the PRO version. The
# developers are kind enough to make it easy to compile it if you know
# how.
{
  stdenv,
  lib,
  giflib,
  SDL2,
  SDL2_sound,
  sdl2-compat,
  alsa-lib,
  argparse,
  curl,
  cmake,
  fetchFromGitHub,
  freeglut,
  git,
  gtk3,
  libGLU,
  libglvnd,
  libsamplerate,
  mesa,
  pkg-config,
  sndio,
  zlib,
  lua54Packages,

  pulseaudioSupport ? stdenv.isLinux,
  libpulseaudio,

  jsSupport ? true,
  quickjs,

  waylandSupport ? true,
  wayland,
  wayland-scanner,
  libxkbcommon,
  libdecor,

  esoundSupport ? true,
  espeak,

  jackSupport ? true,
  jack2,

  # As of 2025-03-26, it is basically required to have a very specific version of
  # mruby so no...
  rubySupport ? false,
  mruby,

  pythonSupport ? true,

  janetSupport ? true,
  janet,

  # This doesn't have the appropriate system library as of nixpkgs 2025-03-26, btw.
  wasmSupport ? true,
  wasm,

  withPro ? true,
}:

# TODO: Fix the timestamp in the help section.
stdenv.mkDerivation (finalAttrs: {
  pname = "tic-80";
  version = "unstable-2026-02-23";

  src = fetchFromGitHub {
    owner = "nesbox";
    repo = "TIC-80";
    rev = "ae1195a9d0fbda243bf0ebd861d6876d072a979e";
    hash = "sha256-oXXLTCkMfB1q16mIq612fieTkleRYN/tP7SBtlRIEKA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    argparse
    alsa-lib
    curl
    freeglut
    gtk3
    giflib
    libsamplerate
    libGLU
    libglvnd
    lua54Packages.lua
    mesa
    git
    sdl2-compat
    SDL2
    SDL2_sound
    zlib
    sndio
  ]
  ++ lib.optionals pulseaudioSupport [ libpulseaudio ]
  ++ lib.optionals jackSupport [ jack2 ]
  ++ lib.optionals jsSupport [ quickjs ]
  ++ lib.optionals esoundSupport [ espeak ]
  ++ lib.optionals rubySupport [ mruby ]
  ++ lib.optionals janetSupport [ janet ]
  ++ lib.optionals wasmSupport [ wasm ]
  ++ lib.optionals (stdenv.isLinux && waylandSupport) [
    wayland
    wayland-scanner
    libxkbcommon
    libdecor
  ];

  cmakeFlags =
    # Just leave the tinier libraries alone for this.
    [
      "-DPREFER_SYSTEM_LIBRARIES=ON"
      "-DBUILD_WITH_FENNEL=ON"
      "-DBUILD_WITH_MOON=ON"
      "-DBUILD_WITH_SCHEME=ON"
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ]
    ++ lib.optionals withPro [ "-DBUILD_PRO=ON" ]
    ++ lib.optionals jsSupport [ "-DBUILD_WITH_JS=ON" ]
    ++ lib.optionals rubySupport [ "-DBUILD_WITH_RUBY=ON" ]
    ++ lib.optionals pythonSupport [ "-DBUILD_WITH_PYTHON=ON" ]
    ++ lib.optionals wasmSupport [ "-DBUILD_WITH_WASM=ON" ]
    ++ lib.optionals janetSupport [ "-DBUILD_WITH_JANET=ON" ];

  # Export all of the TIC-80-related utilities.
  outputs = [
    "out"
    "dev"
  ];
  postInstall = ''
    install -Dm755 bin/* -t $dev/bin
    install -Dm644 lib/* -t $dev/lib
    install -Dm644 ../include/* -t $dev/include

    mkdir -p $out/share/tic80
    cp -r ../demos $out/share/tic80/
  '';

  meta = with lib; {
    description = "A fantasy computer with built-in game dev tools.";
    homepage = "https://tic80.com/";
    license = licenses.mit;
  };
})
