{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.zed-editor;
in {
  options.users.foo-dogsquared.programs.zed-editor.enable =
    lib.mkEnableOption "foo-dogsqured's Zed editor setup";

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      mutableUserDebug = true;
      mutableUserKeymaps = true;
    };
  };
}
