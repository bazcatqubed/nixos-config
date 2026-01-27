# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# Bundling everything for my fullstack (in JS) webdev needs.
{
  mkShell,
  nodejs,
  bun,
  esbuild,
  pnpm,
}:

mkShell {
  packages = [
    nodejs
    bun
    esbuild
    pnpm
  ];
}
