{
  config,
  lib,
  helpers,
  hmConfig,
  ...
}:

let
  inherit (hmConfig.xdg) userDirs;
  nixvimCfg = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfg.setups.fuzzy-finding;
in
{
  options.nixvimConfigs.fiesta-fds.setups.fuzzy-finding.enable =
    lib.mkEnableOption "fuzzy finding setup within fiesta-fds";

  config = lib.mkIf cfg.enable {
    nixvimConfigs.fiesta.setups.fuzzy-finder.enable = true;

    plugins.telescope.extensions.frecency = {
      enable = true;
      settings = {
        show_scores = true;
        show_unindexed = true;
        workspaces = {
          writings = "${userDirs.documents}/Writings";
          packages = "${userDirs.extraConfig.XDG_PROJECTS_DIR}/packages";
          software = "${userDirs.extraConfig.XDG_PROJECTS_DIR}/software";
        };
      };
    };
  };
}
