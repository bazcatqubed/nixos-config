# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  lib,
  self,
}:

let
  nixvimConfig = {
    plugins.lightline.enable = true;

    plugins.neorg.enable = true;
  };

  nixosConfig = {
    programs.firefox.enable = true;
  };

  nixvimConfig' = {
    inherit nixosConfig;
  }
  // nixvimConfig;
in
lib.runTests {
  testNixvimIsStandalone = {
    expr = self.nixvim.isStandalone nixvimConfig;
    expected = true;
  };

  testNixvimIsStandalone2 = {
    expr = self.nixvim.isStandalone nixvimConfig';
    expected = false;
  };
}
