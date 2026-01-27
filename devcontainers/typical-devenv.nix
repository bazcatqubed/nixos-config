# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  dockerTools,
  neovim,
  nushell,
  foodogsquaredLib,
}:

foodogsquaredLib.buildDockerImage rec {
  name = "typical-devenv";
  tag = name;
  contents = foodogsquaredLib.stdenv;
}
