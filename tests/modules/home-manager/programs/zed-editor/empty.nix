# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ ... }:

{
  programs.zed-editor.enable = true;

  test.stubs.zed-editor = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/zed/settings.json
  '';
}
