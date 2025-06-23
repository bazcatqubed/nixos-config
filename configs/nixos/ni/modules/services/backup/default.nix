# It's a setup for my backup.
{ config, lib, pkgs, foodogsquaredLib, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.services.backup;

  borgJobCommonSetting = { patterns ? [ ], passCommand, ... }@args:
    let args' = lib.attrsets.removeAttrs args [ "patterns" "passCommand" ];
    in {
      compression = "zstd,12";
      dateFormat = "+%F-%H-%M-%S-%z";
      doInit = false;
      encryption = {
        inherit passCommand;
        mode = "repokey-blake2";
      };
      extraCreateArgs = let
        patternsFromArgs = lib.map (patternFile: "--patterns-from ${patternFile}") patterns;
      in lib.concatStringsSep " "
        (patternsFromArgs ++ [
          "--exclude-if-present .nobackup"
          "--stats"
        ]);
      extraInitArgs = "--make-parent-dirs";

      # We're emptying them since we're specifying them all through the patterns file.
      paths = lib.mkForce [ ];

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
    } // args';

  hetzner-boxes-user = "u332477";
  hetzner-boxes-server = "${hetzner-boxes-user}.your-storagebox.de";

  pathPrefix = "borg-backup";
in {
  options.hosts.ni.services.backup.enable =
    lib.mkEnableOption "backup setup with BorgBackup and Snapper";

  config = lib.mkIf cfg.enable {
    sops.secrets = foodogsquaredLib.sops-nix.getSecrets ./secrets.yaml
      (foodogsquaredLib.sops-nix.attachSopsPathPrefix pathPrefix {
        "patterns/home" = { };
        "patterns/root" = { };
        "patterns/keys" = { };
        "repos/archives/password" = { };
        "repos/external-hdd/password" = { };
        "repos/hetzner-box/password" = { };
        "repos/hetzner-box/ssh-key" = { };
      });

    suites.filesystem.setups = { laptop-ssd.enable = true; };

    services.borgbackup.jobs = {
      local-external-storage = borgJobCommonSetting {
        patterns = with config.sops; [
          secrets."${pathPrefix}/patterns/root".path
          secrets."${pathPrefix}/patterns/keys".path
        ];
        passCommand = "cat ${
            config.sops.secrets."${pathPrefix}/repos/external-hdd/password".path
          }";
        removableDevice = true;
        doInit = true;
        repo = "${config.state.paths.laptop-ssd}/Backups";
      };

      remote-backup-hetzner-box = borgJobCommonSetting {
        patterns = with config.sops;
          [ secrets."${pathPrefix}/patterns/home".path ];
        passCommand = "cat ${
            config.sops.secrets."${pathPrefix}/repos/hetzner-box/password".path
          }";
        doInit = true;
        repo =
          "ssh://${hetzner-boxes-user}@${hetzner-boxes-server}:23/./borg/desktop/ni";
        startAt = "04:30";
        environment.BORG_RSH = "ssh -i ${
            config.sops.secrets."${pathPrefix}/repos/hetzner-box/ssh-key".path
          }";
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
