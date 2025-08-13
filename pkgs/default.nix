{ pkgs ? import <nixpkgs> { } }:

let inherit (pkgs) lib callPackage python3Packages qt5;
in lib.makeScope pkgs.newScope (self: {
  # My custom nixpkgs extensions.
  foodogsquaredLib = import ../lib { inherit pkgs; };
  inherit (self.foodogsquaredLib.builders)
    makeXDGMimeAssociationList makeXDGPortalConfiguration makeXDGDesktopEntry
    buildHugoSite buildMdbookSite buildMkdocsSite buildAntoraSite buildFDSEnv
    buildDconfDb buildDconfProfile buildDconfConf buildDconfPackage
    buildDockerImage;
  inherit (self.foodogsquaredLib.fetchers) fetchInternetArchive fetchUgeeDriver
    fetchWebsiteIcon fetchPexelsImages fetchPexelsVideos fetchUnsplashImages;

  # My custom packages.
  awesome-cli = callPackage ./awesome-cli { };
  base16-builder-go = callPackage ./base16-builder-go { };
  blender-blendergis = python3Packages.callPackage ./blender-blendergis { };
  blender-machin3tools = python3Packages.callPackage ./blender-machin3tools { };
  clidle = callPackage ./clidle.nix { };
  ctrld = callPackage ./ctrld { };
  domterm = qt5.callPackage ./domterm { };
  fastn = callPackage ./fastn { };
  flatsync = callPackage ./flatsync { };
  freerct = callPackage ./freerct.nix { };
  gnome-search-provider-recoll =
    callPackage ./gnome-search-provider-recoll.nix { };
  #graphite-design-tool = callPackage ./graphite-design-tool { };
  go-avahi-cname = callPackage ./go-avahi-cname { };
  hush-shell = callPackage ./hush-shell.nix { };
  kip = callPackage ./kip { };
  lazyjj = callPackage ./lazyjj { };
  lwp = callPackage ./lwp { };
  moac = callPackage ./moac.nix { };
  mopidy-beets = callPackage ./mopidy-beets.nix { };
  mopidy-funkwhale = callPackage ./mopidy-funkwhale.nix { };
  mopidy-internetarchive = callPackage ./mopidy-internetarchive.nix { };
  mopidy-listenbrainz = callPackage ./mopidy-listenbrainz { };
  nautilus-annotations = callPackage ./nautilus-annotations { };
  pop-launcher-plugin-brightness =
    callPackage ./pop-launcher-plugin-brightness { };
  pop-launcher-plugin-duckduckgo-bangs =
    callPackage ./pop-launcher-plugin-duckduckgo-bangs.nix { };
  pop-launcher-plugin-jetbrains =
    callPackage ./pop-launcher-plugin-jetbrains { };
  pigeon-mail = callPackage ./pigeon-mail { };
  swh = callPackage ./software-heritage {
    python3Packages = pkgs.python312Packages;
  };
  #pd-l2ork = callPackage ./pd-l2ork { };
  #rotp-modnar = callPackage ./rotp-modnar { };
  #rotp-fusion = callPackage ./rotp-fusion { };
  #purrdata = callPackage ./purr-data { };
  speki = callPackage ./speki { };
  sqlc-gen-from-template = callPackage ./sqlc-gen-from-template { };
  tic-80-unstable = callPackage ./tic-80 { };
  smile = callPackage ./smile { };
  sessiond = callPackage ./sessiond { };
  uwsm = callPackage ./uwsm { };
  vgc = qt5.callPackage ./vgc { };
  watc = callPackage ./watc { };
  willow = callPackage ./willow { };
  wzmach = callPackage ./wzmach { };
  xs = callPackage ./xs { };
})
