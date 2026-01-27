# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "sqlc-gen-from-template";
  version = "unstable-2025-01-30";

  src = fetchFromGitHub {
    owner = "fdietze";
    repo = "sqlc-gen-from-template";
    rev = "1bd97b6945ef262a8ad6f4f8ec034c91c2a4365c";
    hash = "sha256-v0j5cV32ebfrqASZi/lva5nAxaMS1hgZlsnTIJSi6Do=";
  };

  vendorHash = "sha256-NsE42mhU5ekNJUu9zFNK/FCJ8S1wB9teHqqSHLKGVyw=";

  meta = with lib; {
    homepage = "https://github.com/fdietze/sqlc-gen-from-template";
    description = "sqlc plugin for generating from a template";
    license = [ licenses.mit ];
    mainProgram = pname;
  };
}
