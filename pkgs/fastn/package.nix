# SPDX-FileCopyrightText: 2023-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fastn";
  version = "0.4.113";

  src = fetchFromGitHub {
    owner = "fastn-stack";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-XJnmu5hh/bvh9+gn3NYJW87a5ZU4w3jyrcfzLrJY7Mk=";
  };

  cargoHash = "sha256-cdLiP5XTDTb+p5b8ufAicflnPYDJvmxXAEQnVjhjOKk=";
  cargoBuildFeatures = [ "edition2024" ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    cmake
    pkg-config
  ];
  buildInputs = [ openssl ];

  checkFlags = [ "--skip=tests::fbt" ];

  meta = with lib; {
    homepage = "https://fastn.com/";
    description = "An integrated development environment for FTD";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
    mainProgram = "fastn";
  };
})
