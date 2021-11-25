# A module that automates setting up agenix for your system.
{ inputs, lib, options, config, ... }:

let
  cfg = config.modules.agenix;
in {
  options.modules.agenix.enable = lib.mkEnableOption "Enable agenix on your system";

  imports = [ inputs.agenix.nixosModules.age ];
  config = lib.mkIf cfg.enable {
    # Enable all relevant services.
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.sshd.enable = true;
    services.openssh.enable = true;
  };
}
