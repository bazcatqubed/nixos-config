# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:

{
  programs.pop-launcher.enable = true;

  test.stubs.pop-launcher = { };

  nmt.script = ''
    assertDirectoryEmpty home-files/.local/share/pop-launcher
  '';
}
