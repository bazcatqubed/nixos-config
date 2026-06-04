# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ formats }:

{
  config,
  lib,
  options,
  ...
}:

let
  cfg = config.komga;
  settingsFormat = formats.yaml { };
in
{
  options.komga = {
    package = lib.mkOption {
      type = lib.types.package;
      defaultText = "The `komga` package provided from the nixpkgs instance.";
      description = ''
        Derivation containing Komga executables for the service.
      '';
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        Server settings in YAML format.
      '';
    };

    settingsFile = lib.mkOption {
      type = lib.types.path;
      default = settingsFormat.generate "komga-settings" cfg.settings;
      defaultText = "Generated file from {option}`komga.settings`.";
      example = "/home/homeless-man/.config/komga/application.yaml";
    };

    rootDir = lib.mkOption {
      type = lib.types.path;
      description = ''
        Root directory of the service where it stores its state and
        configuration.
      '';
    };
  };

  config = {
    process.argv = [
      (lib.getExe cfg.package)
    ];

    configData."application.yaml".source = cfg.settingsFile;
  }
  // lib.optionalAttrs (options ? systemd) {
    systemd.mainExecStart = config.systemd.lib.escapeSystemdExecArgs config.process.argv;

    systemd.service = {
      RemoveIPC = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      SystemCallFilter = [ "@system-service" ];
      PrivateTmp = true;
      ProtectProc = "invisible";
      ProtectClock = true;
      ProcSubset = "all";
      PrivateUsers = true;
      PrivateDevices = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      LockPersonality = true;
      RestrictNamespaces = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
    };
  };
}
