# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  stdenvNoCC,
  lib,
  fetchzip,
  fetchurl,
  curl,
}:

{
  id,
  file ? "",
  formats ? [ ],
  hash ? "",
  name ? "internet-archive-${id}",
}@args:

let
  isFormatIndiciated = formats != [ ];
  url =
    if isFormatIndiciated then
      "https://archive.org/compress/${lib.escapeURL id}/formats=${lib.concatStringsSep "," formats}"
    else
      "https://archive.org/download/${lib.escapeURL id}/${lib.escapeURL file}";

  args' =
    lib.removeAttrs args [
      "id"
      "file"
      "formats"
    ]
    // {
      inherit url hash name;
    };

  fetcher = if isFormatIndiciated then fetchzip else fetchurl;
in
fetcher args'
