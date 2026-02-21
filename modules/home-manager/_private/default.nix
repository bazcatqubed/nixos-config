# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  imports = [
    ../../nixos/_private/fds-lib.nix
    ./extra-arguments.nix
    ./state
    ./suites/desktop.nix
    ./suites/dev.nix
    ./suites/editors.nix
    ./suites/i18n.nix
  ];
}
