{ config, lib, pkgs, ... }:

let
  cfg = config.services.yt-dlp;

  serviceLevelArgs = lib.escapeShellArgs cfg.extraArgs;

  jobUnitName = name: "yt-dlp-archive-service-${name}";

  jobType = { name, config, options, ... }: {
    options = {
      urls = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = ''
          A list of URLs to be downloaded to {command}`yt-dlp`. Please
          see the list of extractors with `--list-extractors`.
        '';
        example = lib.literalExpression ''
          [
            "https://www.youtube.com/c/ronillust"
            "https://www.youtube.com/c/Jazza"
          ]
        '';
      };

      startAt = lib.mkOption {
        type = with lib.types; str;
        description = ''
          Indicates how frequent the download will occur. The given schedule
          should follow the format as described from
          {manpage}`systemd.time(5)`.
        '';
        default = "daily";
        example = "*-*-3/4";
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description =
          "Job-specific extra arguments to be passed to the {command}`yt-dlp`.";
        default = [ ];
        example = lib.literalExpression ''
          [
            "--date" "today"
          ]
        '';
      };
    };
  };
in
{
  options.services.yt-dlp = {
    enable = lib.mkEnableOption "archiving service with yt-dlp";

    package = lib.mkOption {
      type = lib.types.package;
      description =
        "The derivation that contains {command}`yt-dlp` binary.";
      default = pkgs.yt-dlp;
      defaultText = lib.literalExpression "pkgs.yt-dlp";
      example = lib.literalExpression
        "pkgs.yt-dlp.override { phantomjsSupport = true; }";
    };

    archivePath = lib.mkOption {
      type = lib.types.str;
      description = ''
        The location of the archive to be downloaded. Must be an absolute path.
      '';
      example = "/var/archives/yt-dlp-service";
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description =
        "List of arguments to be passed to {command}`yt-dlp`.";
      default = [ "--download-archive videos" ];
      example = lib.literalExpression ''
        [
          "--verbose"
          "--download-archive" "''${cfg.archivePath}/download-list"
          "--concurrent-fragments" "2"
          "--retries" "20"
        ]
      '';
    };

    jobs = lib.mkOption {
      type = with lib.types; attrsOf (submodule jobType);
      description = ''
        A map of jobs for the archiving service.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          arts = {
            urls = [
              "https://www.youtube.com/c/Jazza"
            ];
            startAt = "weekly";
            extraArgs = [ "--date" "today" ];
          };

          compsci = {
            urls = [
              "https://www.youtube.com/c/K%C3%A1rolyZsolnai"
              "https://www.youtube.com/c/TheCodingTrain"
            ];
            startAt = "weekly";
          };
        }
      '';
    };
  };

  # There's no need to go to the working directory since yt-dlp has the
  # `--paths` flag.
  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs'
      (name: value:
        let
          jobLevelArgs = lib.escapeShellArgs value.extraArgs;
        in
        lib.nameValuePair (jobUnitName name) {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          description = "yt-dlp archive job for group '${name}'";
          documentation = [ "man:yt-dlp(1)" ];
          enable = true;
          path = [ cfg.package pkgs.coreutils ];
          preStart = ''
            mkdir -p ${lib.escapeShellArg cfg.archivePath}
          '';
          script = ''
            yt-dlp ${serviceLevelArgs} ${jobLevelArgs} \
                   ${lib.escapeShellArgs value.urls} --paths ${lib.escapeShellArg cfg.archivePath}
          '';
          startAt = value.startAt;
          serviceConfig = {
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateTmp = true;
            PrivateUsers = true;
            PrivateDevices = true;
            ProtectControlGroups = true;
            ProtectClock = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            StandardOutput = "journal";
            StandardError = "journal";
            SystemCallFilter = "@system-service";
            SystemCallErrorNumber = "EPERM";
          };
        })
      cfg.jobs;

    systemd.timers = lib.mapAttrs'
      (name: value:
        lib.nameValuePair (jobUnitName name) {
          timerConfig = {
            Persistent = true;
            RandomizedDelaySec = "2min";
          };
        })
      cfg.jobs;
  };
}
