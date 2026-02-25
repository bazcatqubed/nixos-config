# SPDX-FileCopyrightText: 2023-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

final: prev:

{
  blender-foodogsquared = final.blender.withPackages (
    p: with p; [
      pandas
      scipy
      pillow
      (colour-science.override {
        optionalFeatures = false;
      })
    ]
  );
}
