{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.development;
in {
  options.hosts.ni.setups.development.enable =
    lib.mkEnableOption "software development setup";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Bring all of the software development goodies.
      suites.dev = {
        enable = true;
        extras.enable = true;
        hardware.enable = true;
        containers.enable = true;
        virtual-machines.enable = true;
        security.enable = true;
        neovim.enable = true;
      };

      # Allow USB redirections to machines.
      virtualisation.spiceUSBRedirection.enable = lib.mkDefault true;

      virtualisation.docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        logDriver = "journald";
      };

      environment.systemPackages = with pkgs; [
        # For debugging build environments in Nix packages.
        cntr

        freecad
      ];

      # Enable the terminal emulator of choice.
      programs.wezterm.enable = true;

      # Enable them debugging your mobile tracker.
      programs.adb.enable = true;

      # Installing Guix within NixOS. Now that's some OTP rarepair material right
      # there.
      services.guix = {
        enable = true;
        gc = {
          enable = true;
          dates = "weekly";
        };
      };

      # Userland schedulers.
      services.scx = {
        enable = true;
        package = pkgs.scx.rustscheds;
        scheduler = "scx_rustland";
      };

      # Adding a bunch of emulated systems for cross-system building.
      boot.binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];
    }

    (lib.mkIf config.suites.dev.containers.enable {
      state.ports.cockpit.value = 9090;

      services.cockpit = {
        enable = false;
        port = config.state.ports.cockpit.value;
        settings = { WebService.AllowUnencrypted = true; };
      };

      # Setting up a single-node k3s cluster for learning purposes.
      services.k3s = {
        enable = false;
        role = "server";
      };

      services.openiscsi = {
        enable = true;
        name = "iqn.2025-01.one.foodogsquared:ni-nixos";
      };

      environment.systemPackages = with pkgs; [
        kubernetes-helm
        kubernetes-polaris
        k9s
      ];

      networking.firewall.allowedTCPPorts = lib.optionals config.services.k3s.enable [
        6443 # required so that pods can reach the API server (running on port 6443 by default)
        2379 # etcd clients: required if using a "High Availability Embedded etcd" configuration
        2380 # etcd peers: required if using a "High Availability Embedded etcd" configuration
        8080 # for helm.
        5001
        10250
        51820
        51821
      ];

      networking.firewall.allowedUDPPorts = lib.optionals config.services.k3s.enable [
        8472 # flannel: required if using multi-node for inter-node networking
      ];
    })

    # You'll be most likely having these anyways and even if this is disabled,
    # you most likely cannot use the system at all so WHY IS IT HERE?
    (lib.mkIf hostCfg.networking.enable {
      environment.systemPackages = with pkgs; [
        # Some sysadmin thingamajigs.
        openldap

        # Searchsploit.
        exploitdb
      ];

      # Be a networking doctor or something.
      programs.mtr.enable = true;

      # Wanna be a wannabe haxxor, kid?
      programs.wireshark.package = pkgs.wireshark;

      # Modern version of SSH.
      programs.mosh.enable = true;
    })
  ]);
}
