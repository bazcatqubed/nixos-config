# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ lib, ... }:

{
  services.bleachbit = {
    enable = true;
    startAt = "weekly";
    cleaners = [
      "firefox.cookies"
      "firefox.history"
      "discord.logs"
      "zoom.logs"
    ];
  };

  test.stubs.bleachbit = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/bleachbit.service
    assertFileExists home-files/.config/systemd/user/bleachbit.timer
  '';
}
