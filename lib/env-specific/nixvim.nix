# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs,
  lib,
  self,
}:

{
  isStandalone = config: !config ? hmConfig && !config ? nixosConfig && !config ? darwinConfig;
}
