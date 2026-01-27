# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule (finalAttrs: {
  pname = "grant";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "anchore";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-v08bA6ZWAY6/JW01hB1v02FAWozC/EVrxQeok7tfTx4=";
  };

  vendorHash = "sha256-nb3P85UWRiRgSE+rErHiJBi7lzQ5XckE9svUN5z7nDk=";

  # Uses network.
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/anchore/grant";
    license = licenses.asl20;
    description = "License scanner for container images";
  };
})
