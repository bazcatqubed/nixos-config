# SPDX-FileCopyrightText: 2025-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.zed-editor;
in
{
  options.users.foo-dogsquared.programs.zed-editor.enable =
    lib.mkEnableOption "foo-dogsqured's Zed editor setup";

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;

      mutableUserDebug = true;
      mutableUserKeymaps = true;

      extensions = [
        "nix"
        "toml"
        "latex"
        "scheme"
        "xml"
        "lua"
        "ruby"
        "git-firefly"
        "dart"
      ]
      ++ lib.optionals userCfg.programs.nushell.enable [ "nu" ];
    };
  };
}
