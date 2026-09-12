# SPDX-FileCopyrightText: 2026 Gabriel Arazas <__personal__@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  lib,
  helix-steel,
  tree-sitter-grammars,
  runCommand,
  removeReferencesTo,
  symlinkJoin,
  makeBinaryWrapper,
}:

let
  grammarsFarm = runCommand "helix-grammars" { } (
    lib.concatMapStringsSep "\n" (grammar: ''
              install -D ${grammar}/parser $out/${grammar.language}.so
      ${lib.getExe removeReferencesTo} -t ${grammar} $out/${grammar.language}.so
    '') tree-sitter-grammars.allGrammars
  );

  runtimeDir = runCommand "helix-runtime" { } ''
    mkdir -p $out
    ln -s ${grammarsFarm} $out/grammars
    cp -r --no-preserve=mode ${helix-steel.src}/runtime/queries $out/queries
  '';
in
symlinkJoin {
  pname = "helix-steel-wrapper";
  inherit (helix-steel) version;

  paths = [ helix-steel ];
  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    wrapProgram $out/bin/hx --set HELIX_RUNTIME ${runtimeDir}
  '';

  passthru = {
    runtime = runtimeDir;
    tree-sitter-grammars = grammarsFarm;
  };

  meta = {
    description = "Wrapper for Helix";
    mainProgram = "hx";
    platforms = helix-steel.meta.platforms;
  };
}
