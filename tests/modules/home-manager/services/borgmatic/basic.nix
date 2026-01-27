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
  services.borgmatic.jobs.personal = {
    settings = {
      hello = "WORLD";
    };
  };

  test.stubs.borgmatic = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/borgmatic-job-personal.service
    assertFileExists home-files/.config/systemd/user/borgmatic-job-personal.timer
  '';
}
