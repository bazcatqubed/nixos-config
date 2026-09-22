# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  rotp,
  fetchFromGitHub,
}:

rotp.overrideAttrs (
  finalAttrs: prevAttrs: {
    src = fetchFromGitHub {

    };
  }
)
