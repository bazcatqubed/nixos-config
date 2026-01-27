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
  services.openrefine = {
    enable = true;
    package = pkgs.openrefine;
  };

  test.stubs.openrefine = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/openrefine.service
  '';
}
