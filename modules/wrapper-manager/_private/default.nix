# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  imports = [
    ../../nixos/_private/fds-lib.nix
    ./extra-arguments.nix
    ./programs/chromium-web-apps.nix
    ./programs/gnome-session.nix
    ./programs/systemd.nix
  ];
}
