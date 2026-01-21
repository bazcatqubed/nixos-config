{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.typst;

  typstPackage = cfg.package.withPackages cfg.extraPackages;
in
{
  options.programs.typst = {
    enable = lib.mkEnableOption "configuration for Typst, a typesetting system";

    package = lib.mkPackageOption pkgs "typst" { };

    extraPackages = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      description = ''
        List of packages to be included with the Typst wrapper through
        `typst.withPackages`.
      '';
      default = [ ];
      example = lib.literalExpression ''
        p: with p; [
          babel
          biceps
          zh-kit
        ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton typstPackage;
  };
}
