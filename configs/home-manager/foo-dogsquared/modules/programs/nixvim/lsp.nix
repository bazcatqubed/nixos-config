# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  ...
}@attrs:

let
  nixvimCfg = config.nixvimConfigs.fiesta-fds;
  cfg = nixvimCfg.setups.lsp;
in
{
  options.nixvimConfigs.fiesta-fds.setups.lsp.enable =
    lib.mkEnableOption "LSP integration within fiesta-fds";

  config = lib.mkIf cfg.enable {
    plugins.lsp.enable = true;
    plugins.lsp.inlayHints = true;

    # Enable all of the LSP servers that I'll likely use.
    plugins.lsp.servers = {
      astro.enable = true; # For Astro.
      blueprint_ls.enable = true; # For Blueprint UI files.
      bashls.enable = true; # For Bash.
      clangd.enable = true; # For C/C++.
      cmake.enable = true; # For CMake.
      cssls.enable = true; # For CSS.
      denols.enable = true; # For Deno runtime.
      dockerls.enable = true; # For Dockerfiles.
      emmet_ls.enable = true; # For emmet support.

      # For Guile Scheme.
      guile_ls = {
        enable = true;
        package = null;
      };

      # For HTML.
      html = {
        enable = true;
        autostart = false;
      };

      jsonls.enable = true; # There's one for JSON?
      lemminx.enable = true; # And for XML?
      ltex.enable = true; # And for LanguageTool, too?
      lua_ls.enable = true; # For Lua.
      mesonlsp.enable = true; # For Meson.
      nil_ls.enable = true; # For Nix.
      nushell.enable = true; # For Nushell.
      pyright.enable = true; # For Python.

      # For Harper integration.
      harper_ls.enable = attrs.hmConfig.users.foo-dogsquared.setups.research.writing.enable or false;

      # For Vale.
      vale_ls = {
        enable = true;
        settings.filetypes = [
          "md"
          "mdx"
          "adoc"
          "rst"
        ];
      };

      # For Rust (even though I barely use it).
      rust_analyzer = {
        enable = true;
        installRustc = false;
        installCargo = false;
      };

      scheme_langserver.enable = true; # For Scheme implementations.
      solargraph.enable = true; # For Ruby.
      systemd_lsp.enable = true; # For systemd units.
      stylua.enable = true; # For Stylua formatter.
      tailwindcss.enable = true; # For Tailwind CSS.
      terraformls.enable = true; # For Terraform.
      ts_ls.enable = true; # For TypeScript.
    };
  };
}
