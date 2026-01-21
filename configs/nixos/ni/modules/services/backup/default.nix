# It's a setup for my backup.
{
  config,
  lib,
  pkgs,
  foodogsquaredLib,
  ...
}:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.backup;

  borgJobCommonSetting =
    {
      patterns ? [ ],
      patternFiles ? [ ],
      passCommand,
      ...
    }@args:
    let
      args' = lib.attrsets.removeAttrs args [
        "patterns"
        "passCommand"
      ];
    in
    {
      compression = "zstd,12";
      dateFormat = "+%F-%H-%M-%S-%z";
      doInit = false;
      encryption = {
        inherit passCommand;
        mode = "repokey-blake2";
      };
      extraCreateArgs =
        let
          patternsFromArgs = lib.map (patternFile: "--patterns-from ${patternFile}") patternFiles;
          patternArgs = lib.map (pattern: "--pattern ${pattern}") patterns;
        in
        lib.concatStringsSep " " (
          patternsFromArgs
          ++ patternArgs
          ++ [
            "--exclude-if-present .nobackup"
            "--stats"
          ]
        );
      extraInitArgs = "--make-parent-dirs";

      paths = cfg.globalPaths;

      persistentTimer = true;
      prune = {
        keep = {
          within = "1d";
          hourly = 8;
          daily = 30;
          weekly = 4;
          monthly = 6;
          yearly = 3;
        };
      };
    }
    // args';

  hetzner-boxes-user = "u332477";
  hetzner-boxes-server = "${hetzner-boxes-user}.your-storagebox.de";

  pathPrefix = "borg-backup";
in
{
  options.hosts.ni.services.backup = {
    enable = lib.mkEnableOption "backup setup with BorgBackup and Snapper";

    globalPaths = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      description = ''
        A set of paths to be included in all of the backup jobs.
      '';
      example = lib.literalExpression ''
        [
          config.services.kavita.dataDir
          config.services.kubernetes.dataDir

          "/var/lib/com.example.Service"
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets.yaml (
      foodogsquaredLib.sops-nix.attachSopsPathPrefix pathPrefix {
        "patterns/keys" = { };
        "repos/external-hdd/password" = { };
      }
    );

    suites.filesystem.setups = {
      laptop-ssd.enable = true;
    };

    services.borgbackup.jobs = {
      local-external-storage = borgJobCommonSetting {
        passCommand = "cat ${config.sops.secrets."${pathPrefix}/repos/external-hdd/password".path}";
        removableDevice = true;
        doInit = true;
        repo = "${config.state.paths.laptop-ssd}/Backups";
      };
    };

    # The filesystem snapshots.
    services.snapper = {
      snapshotInterval = "hourly";
      persistentTimer = true;

      configs = {
        root = {
          SUBVOLUME = "/";
          SPACE_LIMIT = "0.25";
          FREE_LIMIT = "0.25";
          BACKGROUND_COMPARISION = "yes";
          NUMBER_CLEANUP = true;
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 48;
          TIMELINE_LIMIT_DAILY = 30;
          TIMELINE_LIMIT_WEEKLY = 8;
          TIMELINE_LIMIT_MONTHLY = 24;
          TIMELINE_LIMIT_QUARTERLY = 10;
          TIMELINE_LIMIT_YEARLY = 8;
        };

        home = {
          SUBVOLUME = "/home";
          ALLOW_USERS = [ "foo-dogsquared" ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = 300;
          TIMELINE_LIMIT_HOURLY = 24;
          TIMELINE_LIMIT_DAILY = 30;
          TIMELINE_LIMIT_WEEKLY = 12;
        };
      };

      filters = ''
        /tmp
        /var/tmp
        /var/log
        /var/lib/libvirt/images
        /srv
      '';
    };
  };
}
