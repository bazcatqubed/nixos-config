# A home-manager module that simply uses the wrapper-manager module under the
# hood. I just did this because I don't want to reimplement the entire thing
# from scratch lmao.
{ config, pkgs, lib, wrapperManagerLib, ... }:

let
  gnomeSessionCfg = wrapperManagerLib.eval {
    inherit pkgs;
    modules = lib.singleton {
      build.drvName = "${config.home.username}-gnome-session-sessions-from-wrapper-manager-fds";
      programs.gnome-session = cfg;
    };
  };

  gnomeSessionPackage = gnomeSessionCfg.config.build.toplevel;
  cfg = config.programs.gnome-session;
in
{
  options.programs.gnome-session =
    let
      # This is to prevent an infinite recursion error. There should be a better
      # way to access the options from wrapper-manager other than a module
      # argument, I guess.
      emptyWM = wrapperManagerLib.eval { inherit pkgs; };
      in
        emptyWM.options.programs.gnome-session;

  config = lib.mkIf (cfg.sessions != { }) {
    home.packages = lib.singleton gnomeSessionPackage;
    systemd.user.packages = lib.singleton gnomeSessionPackage;
  };
}
