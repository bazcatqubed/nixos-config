# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ ... }:

{
  programs.diceware.enable = true;

  test.stubs.diceware = { };

  nmt.script = ''
    assertPathNotExists home-files/.config/diceware/diceware.ini
  '';
}
