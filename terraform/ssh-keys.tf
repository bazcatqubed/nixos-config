# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

resource "hcloud_ssh_key" "foodogsquared" {
  name       = "foodogsquared@foodogsquared.one"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPR52KfVODfKsgdvYSoQinV3kyOTZ4mtKa0fah5Wkfr foodogsquared@foodogsquared.one"
}
