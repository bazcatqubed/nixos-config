# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  dockerTools,
  foodogsquaredLib,
  nodejs,
  bun,
  pnpm,
}:

foodogsquaredLib.buildLayeredDockerImage rec {
  name = "js-backend";
  tag = name;
  contents = [
    nodejs
    bun
    pnpm
  ];
}
