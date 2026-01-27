# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  imports = [
    ./crowdsec.nix
    ./fail2ban.nix
    ./firewall.nix
    ./nginx.nix
  ];
}
