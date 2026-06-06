{
  pkgs ? import <nixpkgs> { overlays = [ (import ../../../overlays).default ]; },
}:

let
  inherit (pkgs) lib foodogsquaredLib;
in
foodogsquaredLib.buildMarpSlides {
  src = lib.cleanSource ./.;
  formats = [
    "html"
    "pdf"
    "pptx"
  ];
}
