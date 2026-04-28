# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: LGPL-2.1-or-later

nix_plugin_src = [
  'nix-math.cc'
]
nix_plugins_dir = join_paths(libdir, 'nix/plugins/foodogsquared')
NIX_VERSION = '>=2.31'
shared_module(
  'nix-fds-plugins',
  nix_plugin_src,
  dependencies: [
    dependency('nix-expr', version: NIX_VERSION),
  ],
  install: true,
  install_dir: nix_plugins_dir,
)

lix_plugin_src = [
  'lix-math.cc'
]
lix_plugins_dir = join_paths(libdir, 'lix/plugins/foodogsquared')
LIX_VERSION = '>=2.95'
shared_module(
  'lix-fds-plugins',
  lix_plugin_src,
  dependencies: [
    dependency('lix-expr', version: LIX_VERSION),
  ],
  cpp_args: [ '-fcoroutines' ],
  install: true,
  install_dir: lix_plugins_dir,
)
