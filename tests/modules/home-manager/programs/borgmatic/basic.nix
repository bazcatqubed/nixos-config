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
  programs.borgmatic = {
    enable = true;
    backups = {
      personal.settings = {
        hello = "WORLD";
      };

      bizness.settings = {
        hello = "MONEY";
      };
    };
  };

  test.stubs.borgmatic = { };

  nmt.script = ''
    assertFileExists home-files/.config/borgmatic.d/personal.yaml
    assertFileExists home-files/.config/borgmatic.d/bizness.yaml
  '';
}
