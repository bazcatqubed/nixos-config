# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# This is simply to make using my flake modules a bit easier for my private
# configurations.
{ inputs, ... }:

{
  flake.flakeModules = {
    inherit (inputs.fds-core.flakeModules) default baseSetupConfig;
  };
}
