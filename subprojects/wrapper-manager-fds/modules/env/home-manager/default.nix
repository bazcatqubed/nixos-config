{ config, lib, ... }@moduleArgs:

let
  cfg = config.wrapper-manager;
in
{
  imports = [
    ../common.nix
  ];

  config = lib.mkMerge [
    { wrapper-manager.extraSpecialArgs.hmConfig = config; }

    (lib.mkIf moduleArgs?nixosConfig {
      wrapper-manager.sharedModules = [
        ({ lib, ... }: {
          # NixOS already has the option to set the locale so we don't need to
          # have this.
          config.locale.enable = lib.mkDefault false;
        })
      ];
    })

    (lib.mkIf (cfg.packages != {}) {
      home.packages =
        lib.mapAttrsToList (_: wrapper: wrapper.build.toplevel) cfg.packages;
    })
  ] ;
}
