# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    settings = {
      autosave = "off";
      confirm_quit = true;
    };
  };

  test.stubs.zed-editor = { };

  nmt.script = ''
    assertFileExists home-files/.config/zed/settings.json
  '';
}
