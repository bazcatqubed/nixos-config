# It is much more recommended to create a project-specific development
# environment for Lua projects instead.
{ mkShell, gcc, lua, luarocks, stylua, sumneko-lua-language-server }:

mkShell {
  packages = [ lua luarocks stylua sumneko-lua-language-server ];

  inputsFrom = [ lua gcc ];
}
