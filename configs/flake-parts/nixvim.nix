# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ inputs, lib, ... }:

{
  setups.nixvim.configs = {
    fiesta = {
      components = [
        {
          nixpkgsBranch = "nixos-unstable";
          nixvimBranch = "nixvim-unstable";
          neovimPackage = pkgs: pkgs.neovim;
          overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
        }
      ];
    };

    trovebelt = {
      components = lib.cartesianProduct {
        nixpkgsBranch = [ "nixos-unstable" ];
        nixvimBranch = [ "nixvim-unstable" ];
        neovimPackage = [ (pkgs: pkgs.neovim) ];
        overlays = [
          [ inputs.neovim-nightly-overlay.overlays.default ]
          [ ]
        ];
      };
    };
  };

  setups.nixvim.sharedModules = [
    # The rainbow road to ricing your raw materials.
    inputs.self.nixvimModules.bahaghari
  ];

  flake = {
    nixvimModules.default = inputs.fds-core.nixvimModules.default;
  };
}
