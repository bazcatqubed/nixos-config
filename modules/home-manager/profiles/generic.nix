# SPDX-FileCopyrightText: 2026 Gabriel Arazas <__personal__@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}@attrs:

{
  xdg.userDirs.setSessionVariables = !(attrs ? nixosConfig);
}
