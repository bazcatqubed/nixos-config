# SPDX-FileCopyrightText: 2022-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  mkShell,
  go,
  gofumpt,
  gopls,
  callPackage,
}:

let
  nodejsDevshell = callPackage ./nodejs.nix { };
in
mkShell {
  packages = [
    go
    gofumpt
    gopls
  ];

  inputsFrom = [
    go
    nodejsDevshell
  ];
}
