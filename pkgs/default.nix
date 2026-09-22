# SPDX-FileCopyrightText: 2021-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib;

  fds = import ../lib { inherit pkgs; };
  fdsSet = {
    # My custom nixpkgs extensions.
    foodogsquaredLib = fds;
    inherit (fds.builders)
      makeXDGMimeAssociationList
      makeXDGPortalConfiguration
      makeXDGDesktopEntry
      buildHugoSite
      buildMdbookSite
      buildZolaSite
      buildMkdocsSite
      buildAntoraSite
      buildFDSEnv
      buildDconfDb
      buildDconfProfile
      buildDconfConf
      buildDconfPackage
      buildDockerImage
      buildBlenderAddons
      buildSuperColliderQuark
      buildMarpSlides
      buildTypstDocument
      ;
    inherit (fds.fetchers)
      fetchInternetArchive
      fetchUgeeDriver
      fetchWebsiteIcon
      fetchPexelsImages
      fetchPexelsVideos
      fetchUnsplashImages
      fetchSupercolliderQuark
      ;
  };
  newScope = extra: pkgs.newScope (fdsSet // extra);

  excludeList = [
    # `default.nix` itself which goes to an infinite recursion when placed within
    # `<flake-utils>.flattenTree` or any functions travelling in the attrset.
    "default"

    # All of the packages here relies on third-party packages so no...
    "firefox-addons"
  ];
in
lib.removeAttrs (lib.filesystem.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  inherit newScope;
  directory = ./.;
}) excludeList
