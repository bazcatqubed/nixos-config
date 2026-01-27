# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yolk";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-VkiFG+rMr39PN12ACxVRXOz4aOenFhP+rIfZmPTCi0s=";
  };

  cargoHash = "sha256-/ePCdk75xAq+JQFsgW2+ZUodQrZyYYbHYfSYP+of0Og=";

  meta = with lib; {
    description = "Templated dotfile management";
    homepage = "https://elkowar.github.io/yolk";
    license = licenses.mit;
  };
})
