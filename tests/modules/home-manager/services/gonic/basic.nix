# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.gonic = {
    enable = true;
    package = pkgs.gonic;

    settings = {
      music-path = [ config.xdg.userDirs.music ];
      podcast-path = [ "${config.xdg.userDirs.music}/Podcasts" ];
    };
  };

  test.stubs.gonic = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/gonic.service
  '';
}
