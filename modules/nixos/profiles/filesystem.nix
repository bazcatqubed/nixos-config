# A bunch of predefined filesystem configurations for several devices. This is
# nice for setting up shop for certain tasks with the flick of the switch to ON
# (e.g., `config.profiles.filesystem.archive.enable = true`) and not have
# conflicting settings all throughout the configuration.
#
# Much of the filesystem setups are taking advantage of systemd's fstab
# extended options which you can refer to at systemd.mount(5), mount(5), and
# the filesystems' respective manual pages.
{ config, options, lib, pkgs, ... }:

let
  cfg = config.profiles.filesystem;
in
{
  options.profiles.filesystem = {
    setups = {
      archive.enable = lib.mkEnableOption "automounting offline archive";
      external-hdd.enable = lib.mkEnableOption "automounting personal external hard drive";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.setups.archive.enable {
      fileSystems."/mnt/archives" = {
        device = "/dev/disk/by-uuid/6ba86a30-5fa4-41d9-8354-fa8af0f57f49";
        fsType = "btrfs";
        noCheck = true;
        options = [
          # These are btrfs-specific mount options which can found in btrfs.5
          # manual page.
          "subvol=@"
          "noatime"
          "compress=zstd:9"
          "space_cache=v2"

          "noauto"
          "nofail"
          "user"

          "x-systemd.automount"
          "x-systemd.idle-timeout=2"
          "x-systemd.device-timeout=2"
        ];
      };
    })

    (lib.mkIf cfg.setups.external-hdd.enable {
      fileSystems."/mnt/external-storage" = {
        device = "/dev/disk/by-uuid/665A391C5A38EB07";
        fsType = "ntfs";
        noCheck = true;
        options = [
          "nofail"
          "noauto"
          "user"

          "x-systemd.automount"
          "x-systemd.device-timeout=2"
          "x-systemd.idle-timeout=2"
        ];
      };
    })
  ];
}
