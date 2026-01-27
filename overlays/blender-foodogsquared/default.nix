# SPDX-FileCopyrightText: 2023-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

final: prev:

{
  blender-foodogsquared = prev.blender.withPackages (
    p: with p; [
      pandas
      scipy
      pillow
    ]
  );
}
