# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ lib, ... }:

{
  programs.pipewire.enable = true;

  test.stubs.pipewire = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/pipewire/pipewire.conf
    assertPathNotExists home-files/.config/pipewire/pipewire.conf.d
  '';
}
