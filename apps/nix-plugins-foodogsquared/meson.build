# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: LGPL-2.1-or-later

project(
  'nix-plugin-foodogsquared',
  'cpp',
  version: '2026-05-25',
  license: 'LGPL-2.1-or-later',
  default_options: [
    'cpp_std=c++23',
  ],
)

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
sysconfdir = join_paths(prefix, get_option('sysconfdir'))
libdir = join_paths(prefix, get_option('libdir'))

subdir('src')
