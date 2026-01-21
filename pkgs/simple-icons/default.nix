{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "simple-icons";
  version = "16.6.0";

  src = fetchFromGitHub {
    owner = "simple-icons";
    repo = "simple-icons";
    rev = finalAttrs.version;
    hash = "sha256-JxXyjn0BqGCUKHIdgn5tnVef9H1glKI2LeHqHY7ZQU8=";
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/share/simple-icons
    cp -t $out/share/simple-icons -r ./data ./icons
    runHook postBuild
  '';

  doCheck = false;
  dontFixup = true;

  meta = with lib; {
    description = "Set of brand icons";
    homepage = "https://simpleicons.org/";
    license = licenses.cc0;
  };
})
