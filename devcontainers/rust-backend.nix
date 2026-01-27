# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  dockerTools,
  foodogsquaredLib,
  rustc,
  cargo,
  rust-bindgen,
  rust-analyzer,
  nodejs,
}:

foodogsquaredLib.buildDockerImage rec {
  name = "rust-backend";
  tag = name;
  contents = [
    cargo
    rust-bindgen
    rust-analyzer
    rustc
    nodejs
  ];
}
