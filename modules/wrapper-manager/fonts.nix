{ config, lib, pkgs, ... }:

let
  cfg = config.fontconfig;

  fontsModuleFactory = { isGlobal ? false }: {
    enable = lib.mkEnableOption "fontconfig configuration" // {
      default = if isGlobal then false else cfg.enable;
    };

    packages = lib.mkOption {
      type = with lib.types; listOf package;
      description = if isGlobal then ''
        Global list of fonts to be added per wrapper (with the local fonts
        support enabled anyways).
      '' else ''
        List of fonts to be added to the wrapper.
      '';
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          noto-sans
          source-sans-pro
          source-code-pro
          stix
        ]
      '';
    };
  };
in {
  options.fontconfig = fontsModuleFactory { isGlobal = true; };

  wrappers = let
    fontsSubmodule = { config, lib, name, pkgs, ... }:
      let submoduleCfg = config.fontconfig;
      in {
        options.fonts = fontsModuleFactory { isGlobal = false; };

        config = let
          fontCacheConf = pkgs.makeFontsConf {
            inherit (pkgs) fontconfig;
            fontsDirectories = submoduleCfg.packages;
          };
        in lib.mkMerge [
          {
            fonts.packages = cfg.packages;
          }

          (lib.mkIf submoduleCfg.enable {
            env.FONTCONFIG_FILE.value = fontCacheConf;
          })
        ];
      };
  in lib.mkOption {
    type = with lib.types; attrsOf (submodule fontsSubmodule);
  };
}
