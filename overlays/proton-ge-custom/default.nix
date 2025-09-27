final: prev:

let
  mkProtonOverride = displayName: { repoHash ? null, ... }@overrideAttrsArgs:
    (prev.proton-ge-bin.override { steamDisplayName = displayName; }).overrideAttrs (overrideAttrsArgs
      // prev.lib.optionalAttrs (repoHash != null) {
        version = displayName;
        src = prev.fetchzip {
          url = getReleaseUrl displayName;
          hash = repoHash;
        };
      });
  getReleaseUrl = version:
    "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
in
{
  proton-ge-9-27-bin = mkProtonOverride "GE-Proton9-27" {
    pname = "proton-ge-9-27-bin";
    repoHash = "sha256-70au1dx9co3X+X7xkBCDGf1BxEouuw3zN+7eDyT7i5c=";
  };

  proton-ge-9-7-bin = mkProtonOverride "GE-Proton9-7" {
    pname = "proton-ge-9-7-bin";
    repoHash = "sha256-/FXdyPuCe6rD5HoMOHPVlwRXu3DMJ3lEOnRloYZMA8s=";
  };

  proton-ge-10-14-bin = mkProtonOverride "GE-Proton10-14" {
    pname = "proton-ge-10-14-bin";
    repoHash = "sha256-AuH10tZNMGybT7Nr7klLLAMlO4eN2KeU8l6Wps/vg2w=";
  };
}
