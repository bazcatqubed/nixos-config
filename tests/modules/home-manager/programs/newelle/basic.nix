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
  programs.newelle = {
    enable = true;
    settings = {
      virtualization = true;
      display-latex = true;
      websearch-on = true;
      websearch-model = "ddgsearch";
    };
    extensions = lib.singleton (
      pkgs.runCommandLocal "newelle-extension-sample" { } ''
        mkdir -p $out/share/Newelle/extensions && touch $out/share/Newelle/extensions/basic.py
      ''
    );
  };

  test.stubs.newelle = { };

  nmt.script = ''
    assertFileExists home-files/.config/Newelle/extensions/basic.py
  '';
}
