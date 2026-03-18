# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  foodogsquaredLib,
}:

foodogsquaredLib.buildLayeredDockerImage rec {
  name = "typical-devenv";
  tag = name;
  contents = foodogsquaredLib.stdenv;
}
