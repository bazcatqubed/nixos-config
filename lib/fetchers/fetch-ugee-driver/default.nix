# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ fetchzip, lib }:

{
  fileId,
  pid,
  ext ? "gz",
  ...
}@args:

let
  args' = lib.removeAttrs args [
    "fileId"
    "pid"
    "ext"
  ];
in
fetchzip (
  args'
  // {
    url = "https://www.ugee.com/download/file/id/${fileId}/pid/${pid}/ext/${ext}";
  }
)
