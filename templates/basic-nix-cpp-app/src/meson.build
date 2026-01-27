# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

app_srcs = [
  'main.cc',
  ]

NIX_VERSION = '>=2.17'

deps = [
  dependency('nix-cmd', version: NIX_VERSION),
  dependency('nix-main', version: NIX_VERSION),
  dependency('nix-expr', version: NIX_VERSION),
  dependency('nix-store', version: NIX_VERSION),
  ]

executable('app',
  app_srcs,
  dependencies: deps,
  install: true,
  link_args: '-Wl,-lnixfetchers'
  )
