# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.48.1"
    }

    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "2.2.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.17.2"
    }
  }
}
