# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    gitea = {
      source  = "go-gitea/gitea"
      version = "0.5.1"
    }
  }
}
