# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

project('wrapper-manager-bubblewrap-launcher',
  version: '0.1.0',
  license: 'MIT',
  meson_version: '>=0.54.0',
)

configure_file(
  input: 'app.sh',
  output: meson.project_name(),
  install_dir: get_option('bindir'),
  install_mode: 'rwxr-xr-x',
  copy: true,
)
