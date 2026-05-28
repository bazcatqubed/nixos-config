# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ formats }:

{
  config,
  options,
  lib,
  ...
}:

let
  cfg = config.gonic;
  settingsFormat = formats.keyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
    listsAsDuplicateKeys = true;
  };
in
{
  _class = "service";

  options.gonic = {
    package = lib.mkOption {
      description = "Package to use for Gonic server";
      defaultText = "The `gonic` package provided from the nixpkgs instance.";
      type = lib.types.package;
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      description = ''
        Settings to be applied.
      '';
      default = { };
    };

    settingsFile = lib.mkOption {
      type = lib.types.path;
      default = settingsFormat.generate "gonic-settings" cfg.settings;
      description = ''
        Settings file to be used for the service.
      '';
    };
  };

  config = {
    process.argv = [
      (lib.getExe cfg.package)
    ]
    ++ cfg.extraArguments;

    configData."gonic.cfg".source = cfg.settingsFile;
  }
  // (lib.optionalAttrs (options ? systemd) {
    systemd.mainExecStart = config.systemd.lib.escapeSystemdExecArgs config.process.argv;

    systemd.service = {
      after = [ "network.target" ];
      description = "Gonic media server";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
      };
    };
  });
}
