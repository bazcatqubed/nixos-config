{ config, lib, pkgs, ... }:

let
  hostCfg = config.hosts.ni;
  cfg = hostCfg.setups.gaming;
in {
  options.hosts.ni.setups.gaming.enable = lib.mkEnableOption "gaming setup";

  config = lib.mkIf cfg.enable {
    # Bring all of the goodies.
    suites.gaming = {
      enable = true;
      emulators.enable = true;
      retro-computing.enable = true;
    };

    programs.retroarch.cores = with pkgs.libretro; [ pcsx2 dolphin citra mame ];

    # Bring more of them games.
    environment.systemPackages = with pkgs; [
      nexusmods-app # Making your gaming experience to infinite possibilities like the space.
      ruffle # Take a trip to nostalgia lane without the viruses.

      rpcs3
      ryubing

      clonehero # Is a real virtuoso, a rock idol.
      mindustry # Not a Minecraft industry simulator.
      luanti # Free Roblox
      the-powder-toy # Free micro-Minecraft.
      rotp-foodogsquared # Free space Minecraft planet colonization simulator.
    ];

    # Losing only means more possibilities to play.
    programs.dwarf-fortress = {
      enable = true;
      wrapperSettings = {
        enableIntro = true;
        enableFPS = true;
      };
    };

    programs.steam.extraCompatPackages = with pkgs; [
      proton-ge-9-27-bin
      proton-ge-9-7-bin
      proton-ge-10-14-bin
    ];

    xdg.desktopEntries.dwarf-fortress = {
      desktopName = "Dwarf Fortress";
      exec = lib.getExe config.programs.dwarf-fortress.package;
      genericName = "Dwarf Fortress";
      terminal = true;
      icon = pkgs.fetchurl {
        url = "https://upload.wikimedia.org/wikipedia/commons/a/a9/Dwarf_Fortress_Icon.svg";
        hash = "sha256-bnNCf7CuiwlnsEdcBEwbqm5d/1z2xgxmGRdBC9sevmE=";
      };
    };

    # This is somewhat used for streaming games from it.
    programs.steam.remotePlay.openFirewall = true;

    # Yes... Play your Brawl Stars and Clash Royale in NixOS. :)
    virtualisation.waydroid.enable = true;
  };
}
