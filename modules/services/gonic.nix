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

  appName = "gonic";
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
      example = lib.literalExpression ''
        {
          cache-path = "/home/homeless-man/.cache";
          music-path = "/home/homeless-man/Music";
          playlists-path = "/home/homeless-man/Music/Playlists";
        }
      '';
    };

    settingsFile = lib.mkOption {
      type = lib.types.path;
      default = settingsFormat.generate "gonic-settings" cfg.settings;
      description = ''
        Settings file to be used for the service.
      '';
    };

    extraArguments = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        List of extra arguments to be added to the main service process.
      '';
      example = lib.literalExpression ''
        [
          "-jukebox-enabled"
          "-http-log"
        ]
      '';
    };
  };

  config = {
    process.argv = [
      (lib.getExe cfg.package)
      "-config-path"
      cfg.settingsFile
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
        CacheDirectory = appName;
        ConfigurationDirectory = appName;
        RuntimeDirectory = appName;
        StateDirectory = appName;

        CapabilityBoundingSet = [ ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
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
  });
}
