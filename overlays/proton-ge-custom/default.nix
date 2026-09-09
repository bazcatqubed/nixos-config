# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

final: prev:

let
  inherit (prev) stdenvNoCC;

  mkProtonOverride =
    displayName:
    {
      repoHash ? null,
      ...
    }@overrideAttrsArgs:
    prev.proton-ge-bin.overrideAttrs (
      finalAttrs:
      overrideAttrsArgs
      // {
        steamDisplayName = displayName;
        toolName = displayName;
        version = displayName;
      }
      // prev.lib.optionalAttrs (repoHash != null) {
        src = prev.fetchzip {
          urls = getReleaseUrl displayName;
          hash = repoHash;
        };
      }
    );
  getReleaseUrl = version: [
    "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz"
    "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}-${stdenvNoCC.hostPlatform.system}.tar.gz"
    "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}-${stdenvNoCC.hostPlatform.uname.processor}.tar.gz"
  ];

  getGEProton =
    version: repoHash:
    mkProtonOverride "GE-Proton${version}" {
      inherit repoHash;
      pname = "proton-ge-${version}-bin";
    };

  protonGEPackages = {
    inherit getGEProton;

    proton-ge-9-27-bin = getGEProton "9-27" "sha256-70au1dx9co3X+X7xkBCDGf1BxEouuw3zN+7eDyT7i5c=";

    proton-ge-9-7-bin = getGEProton "9-7" "sha256-/FXdyPuCe6rD5HoMOHPVlwRXu3DMJ3lEOnRloYZMA8s=";

    proton-ge-10-14-bin = getGEProton "10-14" "sha256-AuH10tZNMGybT7Nr7klLLAMlO4eN2KeU8l6Wps/vg2w=";

    proton-ge-10-15-bin = getGEProton "10-15" "sha256-VS9oFut8Wz2sbMwtX5tZkeusLDcZP3FOLUsQRabaZ0c=";

    proton-ge-10-19-bin = getGEProton "10-19" "sha256-vV009ZlYFEAI1jkfMql46QnJXekRup5TqajVSc57f3U=";

    proton-ge-10-24-bin = getGEProton "10-24" "sha256-QZBu2C4JrsETY+EV0zs4e921qOxYT9lk0EYXXpOCKLs=";

    proton-ge-10-29-bin = getGEProton "10-29" "sha256-ATtKLEKA+r557FVnBoW/iYrRR4Ki9G8rjlV4+2rki0I=";

    proton-ge-10-34-bin = getGEProton "10-34" "sha256-lzPsYYcrp5NoT3B0WFj3o10Z7tXx7xva1wEP3edeuqM=";

    proton-ge-11-1-bin = getGEProton "11-1" "sha256-I7SSvzQQ/NqdvwjpJ9IFFtAaTS+rgHUyXx0us1vIOnw=";

    proton-ge-11-6-bin = getGEProton "11-6" "sha256-rX27DUrrrHtR1cgyr/424m9JPjrdASIisVGv2vWzMAs=";
  };
in
{
  inherit protonGEPackages;

  inherit (protonGEPackages)
    proton-ge-9-27-bin
    proton-ge-9-7-bin
    proton-ge-10-14-bin
    proton-ge-10-15-bin
    proton-ge-10-19-bin
    proton-ge-10-24-bin
    proton-ge-10-29-bin
    proton-ge-10-34-bin
    proton-ge-11-1-bin
    ;
}
