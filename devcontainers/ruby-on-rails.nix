# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  dockerTools,
  ruby,
  bundix,
  mruby,
  rails-new,
  foodogsquaredLib,
}:

foodogsquaredLib.buildDockerImage {
  name = "ruby-on-rails-${ruby.version}";
  tag = "ror-${ruby.version}";
  contents = [
    ruby
    bundix
    mruby
    rails-new
  ];
}
