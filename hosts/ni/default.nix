{ config, pkgs, lib, ... }:

let
  network = import ../plover/modules/hardware/networks.nix;
  inherit (builtins) toString;
  inherit (network)
    interfaces
    wireguardPort
    wireguardPeers;

  wireguardAllowedIPs = [
    "${interfaces.lan.IPv4.address}/16"
    "${interfaces.lan.IPv6.address}/64"
  ];
  wireguardIFName = "wireguard0";
in
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
        "wireshark"
      ];
      hashedPassword =
        "$6$.cMYto0K0CHbpIMT$dRqyKs4q1ppzmTpdzy5FWP/V832a6X..FwM8CJ30ivK0nfLjQ7DubctxOZbeOtygfjcUd1PZ0nQoQpOg/WMvg.";
      isNormalUser = true;
      createHome = true;
      home = "/home/foo-dogsquared";
      description = "Gabriel Arazas";
    })
  ];

  services.openssh.hostKeys = [{
    path = config.sops.secrets."ni/ssh-key".path;
    type = "ed25519";
  }];

  services.gonic = {
    enable = true;
    settings = {
      listen-addr = "127.0.0.1:4747";
      cache-path = "/var/cache/gonic";
      music-path = [
        "/srv/music"
      ];
      podcast-path = "/var/cache/gonic/podcasts";

      jukebox-enabled = true;

      scan-interval = 1;
      scan-at-start-enabled = true;
    };
  };

  sops.secrets =
    let
      getKey = key: {
        inherit key;
        sopsFile = ./secrets/secrets.yaml;
      };
      getSecrets = secrets:
        lib.mapAttrs'
          (secret: config:
            lib.nameValuePair
              "ni/${secret}"
              ((getKey secret) // config))
          secrets;
    in
    getSecrets {
      ssh-key = { };
      "wireguard/private-key" = {
        group = config.users.users.systemd-network.group;
        reloadUnits = [ "systemd-networkd.service" ];
        mode = "0640";
      };
      "wireguard/preshared-keys/plover" = {
        group = config.users.users.systemd-network.group;
        reloadUnits = [ "systemd-networkd.service" ];
        mode = "0640";
      };
      "wireguard/preshared-keys/phone" = {
        group = config.users.users.systemd-network.group;
        reloadUnits = [ "systemd-networkd.service" ];
        mode = "0640";
      };
    };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  programs.wireshark.package = pkgs.wireshark;

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
    desktop = {
      enable = true;
      audio.enable = true;
      fonts.enable = true;
      hardware.enable = true;
      cleanup.enable = true;
      autoUpgrade.enable = true;
      wine.enable = true;
    };
    dev = {
      enable = true;
      shell.enable = true;
      virtualization.enable = true;
      neovim.enable = true;
    };
    gaming = {
      enable = true;
      emulators.enable = true;
      retro-computing.enable = true;
    };
    vpn.personal.enable = true;
  };

  tasks.backup-archive.enable = true;
  workflows.workflows.a-happy-gnome.enable = true;

  programs.pop-launcher = {
    enable = true;
    plugins = with pkgs; [
      pop-launcher-plugin-duckduckgo-bangs
      pop-launcher-plugin-brightness
    ];
  };

  programs.wezterm.enable = true;
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    # Some sysadmin thingamajigs.
    openldap
    wireguard-tools
    (swh.swh-core.overrideAttrs (attrs: {
      pythonPath = with pkgs.swh; [
        swh-model
        swh-fuse
      ];
    }))

    # For debugging build environments in Nix packages.
    cntr

    # Searchsploit.
    exploitdb
  ];

  # Enable Guix service.
  services.guix.enable = true;

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

  # We'll go with a software firewall. We're mostly configuring it as if we're
  # using a server even though the chances of that is pretty slim.
  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedUDPPorts = [ wireguardPort ];
      allowedTCPPorts = [
        22 # Secure Shells.
      ];
    };
  };

  services.resolved.domains = [
    "~plover.foodogsquared.one"
    "~0.27.172.in-addr.arpa"
    "~0.28.172.in-addr.arpa"
  ];

  system.stateVersion = "23.05"; # Yes! I read the comment!

  # Setting up Wireguard as a VPN tunnel. Since this is a laptop that meant to
  # be used anywhere, we're configuring Wireguard here as a "client".
  #
  # We're using wg-quick here as this host is using network managers that can
  # differ between workflows (i.e., GNOME and KDE Plasma using NetworkManager,
  # others might be using systemd-networkd).
  networking.wg-quick.interfaces.wireguard0 =
    let
      domains = [
        "~plover.foodogsquared.one"
        "~0.27.172.in-addr.arpa"
        "~0.28.172.in-addr.arpa"
      ];
    in
    {
      privateKeyFile = config.sops.secrets."ni/wireguard/private-key".path;
      listenPort = wireguardPort;
      dns = with interfaces.lan; [ IPv4.address IPv6.address ];
      postUp =
        let
          resolvectl = "${lib.getBin pkgs.systemd}/bin/resolvectl";
        in
        ''
          ${resolvectl} domain ${wireguardIFName} ${lib.concatStringsSep " " domains}
          ${resolvectl} dnssec ${wireguardIFName} no
        '';

      address = with wireguardPeers.desktop; [
        "${IPv4}/32"
        "${IPv6}/128"
      ];

      peers = [
        # The "server" peer.
        {
          publicKey = lib.removeSuffix "\n" (lib.readFile ../plover/files/wireguard/wireguard-public-key-plover);
          presharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/plover".path;
          allowedIPs = wireguardAllowedIPs;
          endpoint = "${interfaces.wan.IPv4.address}:${toString wireguardPort}";
          persistentKeepalive = 25;
        }

        # The "phone" peer.
        {
          publicKey = lib.removeSuffix "\n" (lib.readFile ../plover/files/wireguard/wireguard-public-key-phone);
          presharedKeyFile = config.sops.secrets."ni/wireguard/preshared-keys/phone".path;
          allowedIPs = wireguardAllowedIPs;
        }
      ];
    };
}
