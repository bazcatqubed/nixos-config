{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./modules/hardware/traditional-networking.nix
  ];

  # Get the latest kernel for the desktop experience.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # The simpler WiFi manager.
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
        ControlPortOverNL80211 = true;
      };

      Network.NameResolvingService = "systemd";
      Settings.AutoConnect = true;
    };
  };

  # Welp....
  systemd.network.links."80-iwd" = {
    matchConfig = lib.mkForce { };
    linkConfig = lib.mkForce { };
  };

  # Set the NetworkManager backend to iwd for workflows that use it.
  networking.networkmanager.wifi.backend = "iwd";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    netbootxyz.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # We're using some better filesystems so we're using it.
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [
      "/mnt/archives"
    ];
  };

  # Set up printers.
  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      gutenprint
      hplip
      splix
    ];
  };

  # Make your CPU more useful.
  services.auto-cpufreq.enable = true;

  # Extend the life of an SSD.
  services.fstrim.enable = true;
}
