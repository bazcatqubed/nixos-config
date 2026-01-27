# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.kando.enable = true;

  nmt.script = ''
    assertPathNotExists home-files/.config/kando/config.json
    assertPathNotExists home-files/.config/kando/menus.json
  '';
}
