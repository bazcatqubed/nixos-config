# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

final: prev:

let
  packageOverrides = self: super: {
    colour-science = self.callPackage ../../pkgs/colour-science { };
  };

  overridePython =
    py:
    py.override {
      inherit packageOverrides;
      self = py;
    };
in
{
  python3 = overridePython prev.python3;

  python311 = overridePython prev.python311;
  python312 = overridePython prev.python312;
  python314 = overridePython prev.python314;
}
