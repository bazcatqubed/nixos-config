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
  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "Your name";
      user.email = "yourname@example.com";
    };
  };

  build.extraPassthru.tests = {
    runWithJujutsu =
      let
        wrapper = config.build.toplevel;
      in
      pkgs.runCommand ''
        [ -x ${lib.getExe' wrapper "jj"} ] && touch $out
      '';
  };
}
