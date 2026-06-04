# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  formats,
}:

{
  options,
  config,
  lib,
  ...
}:

let
  cfg = config.suwayomi-server;
  settingsFormat = formats.hocon { };
in
{
  _class = "service";

  options.suwayomi-server = {
    package = lib.mkOption {
      type = lib.types.package;
      defaultText = "The `suwayomi-server` package provided from the nixpkgs instance.";
      description = ''
        Derivation containing Suwayomi executables for the service.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      description = ''
        Root directory of the service.
      '';
      example = "/home/homeless-man/Documents/Comics";
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Server configuration settings in HOCON format.
      '';
      example = lib.literalExpression ''
        {
          server = {
            ip = "127.0.0.1";
            port = 5689;
            systemTrayEnabled = false;

            downloadAsCbz = true;
            autoDownloadNewChapters = true;
          };
        }
      '';
    };

    settingsFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Location of the configuration file. By default, this points to the
        generated settings from {option}`suwayomi-server.settings`.
      '';
      default = settingsFormat.generate "suwayomi-server-settings" cfg.settings;
    };

    database = lib.mkOption {
      type = lib.types.enum [
        "postgres"
        "h2"
      ];
      default = "h2";
      description = ''
        Dictates what database to be used for this service.
      '';
      example = "postgres";
    };
  };

  config = {
    process.argv = [
      (lib.getExe cfg.package)
      "-Dsuwayomi.tachidesk.config.server.rootDir=${cfg.dataDir}"
    ];

    configData."server.conf".source = cfg.settingsFile;
  }
  // lib.optionalAttrs (options ? systemd) {
    systemd.mainExecStart = config.systemd.lib.escapeSystemdExecArgs config.process.argv;

    systemd.service = {
      PrivateUser = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;

      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      UMask = "0066";
    };
  };
}
