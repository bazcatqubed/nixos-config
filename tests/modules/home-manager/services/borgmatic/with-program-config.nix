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
  programs.borgmatic.enable = true;

  programs.borgmatic.backups.personal = {
    settings.hello = "WORLD";
    initService.enable = true;
  };

  test.stubs.borgmatic = { };

  nmt.script = ''
    assertFileExists home-files/.config/borgmatic.d/personal.yaml
    assertFileExists home-files/.config/systemd/user/borgmatic-job-borgmatic-config-personal.service
    assertFileExists home-files/.config/systemd/user/borgmatic-job-borgmatic-config-personal.timer
  '';
}
