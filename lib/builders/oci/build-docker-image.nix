# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  dockerTools,
  lib,
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
dockerTools.buildImage (
  attrs'
  // {
    name = "fds-${name}";

    copyToRoot = foodogsquaredLib.buildFDSEnv {
      inherit pathsToLink;
      name = "fds-${name}-root";
      paths =
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
    };

    compressor = attrs.compressor or "zstd";

    runAsRoot = ''
      ${lib.optionalString enableTypicalSetup ''
        mkdir -p /data
      ''}
      ${attrs.runAsRoot or ""}
    '';

    config =
      (attrs.config or { })
      // lib.optionalAttrs enableTypicalSetup {
        Cmd = [ "/bin/bash" ];
        WorkingDir = "/data";
        Volumes."/data" = { };
      };
  }
)
