# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  newScope,
  fetchSupercolliderQuark,
}:

lib.makeScope newScope (
  self:
  lib.recurseIntoAttrs {
    SuperDirt = fetchSupercolliderQuark {
      urls = [ "SuperDirt" ];
      hash = "sha256-Ru+ztijPfk7iCbyqAt910Rzz5DJ1R8jl/NTCRetngik=";

      meta = {
        homepage = "https://codeberg.org/musikinformatik/SuperDirt";
        description = "Tidal audio engine";
        license = lib.licenses.gpl2Only;
      };
    };

    SuperDirtMixer = fetchSupercolliderQuark {
      urls = [ "SuperDirtMixer" ];
      hash = "sha256-5rhRrQdPnQ5wgqH0VM3Kb2r9BrXJI4Sd4mbZJKihDwA=";

      meta = {
        homepage = "https://github.com/thgrund/SuperDirtMixer";
        description = "Graphical mixer for SuperDirt";
        license = lib.licenses.gpl3Only;
      };
    };

    MathLib = fetchSupercolliderQuark {
      urls = [ "MathLib" ];
      hash = "sha256-1qzZwZAITLD9AJ58JlL6tmfg3dsjteknnHSyfM+7ZNc=";

      meta = {
        homepage = "https://github.com/supercollider-quarks/MathLib";
        description = "Some mathematical extensions to SuperCollider";
        license = lib.licenses.gpl3Only;
      };
    };

    ZZZ = fetchSupercolliderQuark {
      urls = [ "ZZZ" ];
      hash = "sha256-XKWnzJijQUTTeAjs5Jqpk4NWLYStk5/543GgcwLcx/I=";

      meta = {
        homepage = "https://gitlab.com/dvzrv/zzz";
        description = "SuperCollider classes to interface with Expert Sleepers devices";
        license = lib.licenses.gpl3Only;
      };
    };
  }
)
