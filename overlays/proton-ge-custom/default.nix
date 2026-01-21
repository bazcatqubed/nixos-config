final: prev:

let
  mkProtonOverride =
    displayName:
    {
      repoHash ? null,
      ...
    }@overrideAttrsArgs:
    (prev.proton-ge-bin.override { steamDisplayName = displayName; }).overrideAttrs (
      overrideAttrsArgs
      // prev.lib.optionalAttrs (repoHash != null) {
        version = displayName;
        src = prev.fetchzip {
          url = getReleaseUrl displayName;
          hash = repoHash;
        };
      }
    );
  getReleaseUrl =
    version:
    "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";

  getGEProton =
    version: repoHash:
    mkProtonOverride "GE-Proton${version}" {
      inherit repoHash;
      pname = "proton-ge-${version}-bin";
    };
in
{
  inherit getGEProton;

  proton-ge-9-27-bin = getGEProton "9-27" "sha256-70au1dx9co3X+X7xkBCDGf1BxEouuw3zN+7eDyT7i5c=";

  proton-ge-9-7-bin = getGEProton "9-7" "sha256-/FXdyPuCe6rD5HoMOHPVlwRXu3DMJ3lEOnRloYZMA8s=";

  proton-ge-10-14-bin = getGEProton "10-14" "sha256-AuH10tZNMGybT7Nr7klLLAMlO4eN2KeU8l6Wps/vg2w=";

  proton-ge-10-15-bin = getGEProton "10-15" "sha256-VS9oFut8Wz2sbMwtX5tZkeusLDcZP3FOLUsQRabaZ0c=";

  proton-ge-10-24-bin = getGEProton "10-24" "sha256-QZBu2C4JrsETY+EV0zs4e921qOxYT9lk0EYXXpOCKLs=";
}
