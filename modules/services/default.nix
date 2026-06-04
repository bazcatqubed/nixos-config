# SPDX-FileCopyrightText: 2020-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{ pkgs }:

let
  inherit (pkgs) lib;
in
{
  vouch-proxy.default = {
    imports = lib.singleton (lib.modules.importApply ./vouch-proxy.nix { inherit (pkgs) formats; });

    config = {
      vouch-proxy.package = lib.mkDefault pkgs.vouch-proxy;
    };
  };

  gonic.default = {
    imports = lib.singleton (lib.modules.importApply ./gonic.nix { inherit (pkgs) formats; });

    config = {
      gonic.package = lib.mkDefault pkgs.gonic;
    };
  };

  suwayomi-server.default = {
    imports = lib.singleton (lib.modules.importApply ./suwayomi-server.nix { inherit (pkgs) formats; });

    config = {
      suwayomi-server.package = lib.mkDefault pkgs.suwayomi-server;
    };
  };

  komga.default = {
    imports = lib.singleton (lib.modules.importApply ./komga.nix { inherit (pkgs) formats; });

    config = {
      komga.package = lib.mkDefault pkgs.komga;
    };
  };
}
