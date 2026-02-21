# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  dockerTools,
  foodogsquaredLib,
}:

{
  name,
  contents ? [ ],
  pathsToLink ? [ ],
  enableTypicalSetup ? true,
  ...
}@attrs:

let
  attrs' = lib.removeAttrs attrs [
    "contents"
    "pathsToLink"
    "enableTypicalSetup"
    "name"
  ];
in
dockerTools.buildLayeredImage (
  attrs'
  // {
    inherit name;

    contents =
      contents
      ++ lib.optionals enableTypicalSetup (
        with dockerTools;
        [
          usrBinEnv
          binSh
          caCertificates
          fakeNss
        ]
      );
  }
)
