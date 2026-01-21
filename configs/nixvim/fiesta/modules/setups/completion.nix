{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:

let
  nixvimCfg = config.nixvimConfigs.fiesta;
  cfg = nixvimCfg.setups.completion;
in
{
  options.nixvimConfigs.fiesta.setups.completion.enable =
    lib.mkEnableOption "debugging setup for Fiesta NixVim";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        plugins.blink-cmp = {
          enable = true;
          settings = {
            completion = {
              accept = {
                auto_brackets = {
                  enabled = true;
                  semantic_token_resolution.enabled = true;
                };
              };

              documentation.auto_show = true;
            };
          };
        };
      }

      (lib.mkIf config.nixvimConfigs.fiesta.setups.snippets.enable {
        plugins.blink-cmp.settings.snippets.preset = "luasnip";
      })
    ]
  );
}
