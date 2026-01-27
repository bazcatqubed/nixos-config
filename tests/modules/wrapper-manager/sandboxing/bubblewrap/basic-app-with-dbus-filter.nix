# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# Based from the examples from NixPak.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  build.variant = "shell";
  wrappers.hello = {
    wraparound.variant = "bubblewrap";
    wraparound.subwrapper.arg0 = lib.getExe' pkgs.hello "hello";
    wraparound.bubblewrap.dbus = {
      enable = true;
      filter.addresses = {
        "org.freedesktop.systemd1".policies.level = "talk";
        "org.gtk.vfs.*".policies.level = "talk";
        "org.gtk.vfs".policies.level = "talk";
      };
    };
  };
}
