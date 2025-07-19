{ config, lib, pkgs, ... }:

let
  cfg = config.programs.texlive;
in
{
  disabledModules = [ "programs/texlive.nix" ];

  options.programs.texlive = {
    enable = lib.mkEnableOption "TexLive installation management";

    package = lib.mkPackageOption pkgs "texlive" { example = "pkgs.texliveMedium"; };

    modules = lib.mkOption {
      type = with lib.types; functionTo (listOf package);
      description = ''
        Lambda containing a list of package to be included within the TexLive
        environment.
      '';
      default = ps: [];
      example = lib.literalExpression ''
        ps: with ps; [
          texdoc
          cm-super
        ];
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (cfg.package.withPackages cfg.modules) ];
  };
}
