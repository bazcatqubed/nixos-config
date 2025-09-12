final: prev:

let
  mkProtonOverride = displayName: overrideAttrsArgs:
    (prev.proton-ge-bin.override { steamDisplayName = displayName; }).overrideAttrs overrideAttrsArgs;
  getReleaseUrl = version:
    "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
in
{
  proton-ge-9-27-bin = mkProtonOverride "GE-Proton-9-27" rec {
    pname = "proton-ge-9-27-bin";
    version = "GE-Proton9-27";
    src = prev.fetchzip {
      url = getReleaseUrl version;
      hash = "sha256-70au1dx9co3X+X7xkBCDGf1BxEouuw3zN+7eDyT7i5c=";
    };
  };

  proton-ge-9-7-bin = mkProtonOverride "GE-Proton9-7" rec {
    pname = "proton-ge-9-7-bin";
    version = "GE-Proton9-7";
    src = prev.fetchzip {
      url = getReleaseUrl version;
      hash = "sha256-/FXdyPuCe6rD5HoMOHPVlwRXu3DMJ3lEOnRloYZMA8s=";
    };
  };

  proton-ge-10-14-bin = mkProtonOverride "GE-Proton-10-14" rec {
    pname = "proton-ge-10-14-bin";
    version = "GE-Proton10-14";
    src = prev.fetchzip {
      url = getReleaseUrl version;
      hash = "sha256-AuH10tZNMGybT7Nr7klLLAMlO4eN2KeU8l6Wps/vg2w=";
    };
  };
}
