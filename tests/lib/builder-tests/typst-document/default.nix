{
  pkgs ? import <nixpkgs> { overlays = [ (import ../../../../overlays).default ]; },
}:

let
  inherit (pkgs) lib foodogsquaredLib;
in
foodogsquaredLib.buildTypstDocument {
  src = lib.cleanSource ./.;
  formats = [
    "pdf"
  ];
  vendorHash = "sha256-aAFDSphZiUVuJfugC50Cuhl19Knf1pAyy6NPP3AU+po=";
}
