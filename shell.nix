# SPDX-FileCopyrightText: 2021-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  pkgs ? import <nixpkgs> { },
  extraPackages ? [ ],
}:

let
  run-workflow-in-vm = pkgs.callPackage ./apps/run-workflow-with-vm { };
  fetch-website-icon = pkgs.callPackage ./lib/fetchers/fetch-website-icon/package/package.nix { };
  fds-flock-of-fetchers = pkgs.callPackage ./apps/fds-fetcher-flock/nix/package.nix { };
  nix-fds-plugins = import ./apps/nix-plugins-foodogsquared/nix { inherit pkgs; };
in
pkgs.mkShell {
  packages =
    with pkgs;
    [
      # My internal applications.
      run-workflow-in-vm
      fetch-website-icon
      fds-flock-of-fetchers

      just
      age
      asciidoctor
      disko
      deploy-rs
      hcloud
      npins
      nixos-anywhere
      home-manager
      git
      sops
      reuse
      nix-update
      deadnix
      nixdoc
      nvd

      bind
      opentofu

      # The typical scripting toolkit.
      go
      jq
      wl-clipboard

      # Language servers for various parts of the config that uses a language.
      lua-language-server
      pyright
      nil
      terraform-ls
      gopls

      # Formatters...
      treefmt # The universal formatter (if you configured it).
      stylua # ...for Lua.
      black # ...for Python.
      nixfmt # ...for Nix.

      # Debuggers...
      delve
    ]
    ++ extraPackages;

  # Dunno if this works for non-nixpkgs' stdenv shells (i.e., anything that is
  # not Bash) but better to be safe than sorry in this case.
  env.NIX_CONFIG = ''
    plugin-files = ${nix-fds-plugins}/lib/nix/plugins/foodogsquared
  '';
}
