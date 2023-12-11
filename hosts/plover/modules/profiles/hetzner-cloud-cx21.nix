{ config, lib, pkgs, modulesPath, ... }:

# Most of the filesystems listed here are supposed to be overriden to default
# settings of whatever image format configuration this host system will import
# from nixos-generators.
let
  inherit (builtins) toString;
  inherit (import ./networks.nix) interfaces;

  # This is just referring to the same interface just with alternative names.
  mainEthernetInterfaceNames = [ "ens3" "enp0s3" ];
  internalEthernetInterfaceNames = [ "ens10" "enp0s10" ];
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Hetzner can only support non-UEFI bootloader (or at least it doesn't with
  # systemd-boot).
  boot.loader.grub = {
    enable = lib.mkForce true;
    device = "/dev/sda";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "virtio_scsi" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "nvme" ];

  zramSwap.enable = true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking = {
    enableIPv6 = true;
    usePredictableInterfaceNames = lib.mkDefault true;
    useNetworkd = true;

    # We're using networkd to configure so we're disabling this
    # service.
    useDHCP = false;
    dhcpcd.enable = false;

    # We'll make use of their timeservers.
    timeServers = lib.mkBefore [
      "ntp1.hetzner.de"
      "ntp2.hetzner.com"
      "ntp3.hetzner.net"
    ];
  };

  # The local DNS resolver. This should be used in conjunction with an
  # authoritative DNS server as a forwarder. Also, it should live in its
  # default address at 127.0.0.53 (as of systemd v252).
  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  # The interface configuration is based from the following discussion:
  # https://discourse.nixos.org/t/nixos-on-hetzner-cloud-servers-ipv6/221/
  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "lo" interfaces.lan.ifname ];

    # For more information, you can look at Hetzner documentation from
    # https://docs.hetzner.com/robot/dedicated-server/ip/additional-ip-adresses/
    networks = {
      "10-wan" = with interfaces.wan; {
        matchConfig.Name = lib.concatStringsSep " " mainEthernetInterfaceNames;

        # Setting up IPv6.
        address = [ "${IPv6.address}/64" ];
        gateway = [ IPv6.gateway ];

        # Setting up some other networking thingy.
        domains = [ config.networking.domain ];
        networkConfig = {
          # IPv6 has to be manually configured.
          DHCP = "ipv4";
          IPForward = true;

          LinkLocalAddressing = "ipv6";
          IPv6AcceptRA = true;

          DNS = [
            # The custom DNS servers.
            IPv4.address
            IPv6.address

            "2a01:4ff:ff00::add:2"
            "2a01:4ff:ff00::add:1"
          ];
        };
      };

      # The interface for our LAN.
      "20-lan" = with interfaces.lan; {
        matchConfig.Name = lib.concatStringsSep " " internalEthernetInterfaceNames;

        # Take note of the private subnets set in your Hetzner Cloud instance
        # (at least for IPv4 addresses)..
        address = [
          "${IPv4.address}/16"
          "${IPv6.address}/64"
        ];

        # Using the authoritative DNS server to enable accessing them nice
        # internal services with domain names.
        dns = [
          IPv4.address
          IPv6.address
        ];

        # Force our own internal domain to be used in the system.
        domains = [ config.networking.fqdn ];

        # Use the gateway to enable resolution of external domains.
        gateway = [
          IPv4.gateway
          IPv6.gateway
        ];

        networkConfig.IPv6AcceptRA = true;
      };
    };
  };
}
