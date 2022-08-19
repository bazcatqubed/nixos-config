{ config, pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    (lib.mapHomeManagerUser "foo-dogsquared" {
      extraGroups = [
        "adbusers"
        "wheel"
        "audio"
        "docker"
        "podman"
        "networkmanager"
      ];
      hashedPassword =
        "$6$.cMYto0K0CHbpIMT$dRqyKs4q1ppzmTpdzy5FWP/V832a6X..FwM8CJ30ivK0nfLjQ7DubctxOZbeOtygfjcUd1PZ0nQoQpOg/WMvg.";
      isNormalUser = true;
      createHome = true;
      home = "/home/foo-dogsquared";
      openssh.authorizedKeys.keyFiles = [
        ../../users/home-manager/foo-dogsquared/user-key.pub
      ];
    })
  ];

  services.openssh.hostKeys = [{
    path = config.sops.secrets.ssh-key.path;
    type = "ed25519";
  }];
  sops.secrets.ssh-key.sopsFile = ./secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [
      "/mnt/archives"
    ];
  };

  # My custom configuration with my custom modules starts here.
  profiles = {
    i18n.enable = true;
    archiving.enable = true;
    system = {
      enable = true;
      audio.enable = true;
      fonts.enable = true;
      hardware.enable = true;
      cleanup.enable = true;
      autoUpgrade.enable = true;
    };
    dev = {
      enable = true;
      shell.enable = true;
      virtualization.enable = true;
      neovim.enable = true;
    };
  };

  tasks = {
    multimedia-archive.enable = true;
    backup-archive.enable = true;
  };
  themes.themes.a-happy-gnome.enable = true;

  programs.pop-launcher = {
    enable = true;
    plugins = with pkgs; [
      pop-launcher-plugin-duckduckgo-bangs
      pop-launcher-plugin-jetbrains
      pop-launcher-plugin-brightness
    ];
  };

  programs.wezterm.enable = true;
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    # This is installed just to get Geiser to properly work.
    guile_3_0

    (swh.swh-core.overrideAttrs (super: self: {
      pythonPath = with swh; [
        swh-fuse
        swh-web-client
        swh-model
        swh-auth
      ];
    }))
  ];

  # Enable Guix service.
  services.guix-binary.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Doxxing myself.
  location = {
    latitude = 15.0;
    longitude = 121.0;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;
  services.avahi.enable = true;

  # The usual doas config.
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        persist = true;
      }

      # It is the primary user so we may as well just make this easier to run.
      {
        users = [ "foo-dogsquared" ];
        cmd = "nixos-rebuild";
        noPass = true;
      }
    ];
  };

  system.stateVersion = "22.11"; # Yes! I read the comment!
}
