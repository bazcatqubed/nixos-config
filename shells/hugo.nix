# My usual toolchain for developing Hugo projects.
{ mkShell, hugo, git, go, nodejs_latest }:

mkShell {
  packages = [
    hugo # The main tool.
    go # I might use Go modules which requires the Golang runtime.
    git # VCS of my choice.
    nodejs_latest # The supported NodeJS version.
  ];
}
