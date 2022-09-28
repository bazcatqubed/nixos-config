# Build the TIC-80 virtual computer console with the PRO version. The
# developers are kind enough to make it easy to compile it if you know
# how.
{ stdenv
, lib
, alsaLib
, cmake
, fetchFromGitHub
, freeglut
, gtk3
, libGLU
, git
, libglvnd
, mesa
, SDL2
, pkg-config
, valgrind
, sndio
, libsamplerate
, zlib
, pulseaudioSupport ? stdenv.isLinux
, libpulseaudio
, waylandSupport ? true
, wayland
, libxkbcommon
, esoundSupport ? true
, espeak
, jackSupport ? true
, jack2
, rubySupport ? false
, mruby
, rake
}:

# TODO: Fix the timestamp in the help section.
# TODO: Wait for SDL v2.0.18 for more Wayland support?
stdenv.mkDerivation rec {
  pname = "tic-80";
  version = "unstable-2022-01-18";

  src = fetchFromGitHub {
    owner = "nesbox";
    repo = "TIC-80";
    rev = "06fde1279677273856c1daf9f2fa22e337daba3d";
    sha256 = "sha256-qFjcxb/umrr6CT7yorWCkoDskmKCsMm9frceyF6lXjE=";
    fetchSubmodules = true;
  };

  # We're only replacing 'mruby' since it will have the most complications to
  # build. Also, it uses the same version as the nixpkgs version as of
  # 2021-12-18 which is v3.0.0.
  patches = [ ./change-cmake.patch ];
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace '@mruby@' "${mruby}"
  '';

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    alsaLib
    freeglut
    gtk3
    libsamplerate
    libGLU
    libglvnd
    mesa
    git
    SDL2
    zlib
    mruby
    rake
    valgrind
    sndio
  ] ++ lib.optional pulseaudioSupport libpulseaudio
    ++ lib.optional jackSupport jack2 ++ lib.optional esoundSupport espeak
    ++ lib.optionals (stdenv.isLinux && waylandSupport) [
      wayland
      libxkbcommon
    ];

  # TODO: Replace SOKOL-built version with SDL.
  cmakeFlags = [ "-DBUILD_PRO=ON" "-DBUILD_SDL=OFF" "-DBUILD_SOKOL=ON" ];

  # Export all of the TIC-80-related utilities.
  outputs = [ "out" "dev" ];
  postInstall = ''
    install -Dm755 bin/* -t $dev/bin
    install -Dm644 lib/* -t $dev/lib
    install -Dm644 ../include/* -t $dev/include

    mkdir -p $out/share/tic80
    cp -r ../demos $out/share/tic80/
    mv $out/bin/tic80{-sokol,}
  '';

  meta = with lib; {
    description = "A fantasy computer with built-in game dev tools.";
    homepage = "https://tic80.com/";
    license = licenses.mit;
  };
}
