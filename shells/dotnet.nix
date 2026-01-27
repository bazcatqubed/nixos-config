# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  dotnet-runtime,
  dotnet-sdk,
  mkShell,
}:

mkShell {
  packages = [
    dotnet-runtime
    dotnet-sdk
  ];

  inputsFrom = [ dotnet-sdk ];
}
