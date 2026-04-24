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
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.vs-code;
in
{
  options.users.foo-dogsquared.programs.vs-code.enable =
    lib.mkEnableOption "foo-dogsquared's Visual Studio Code setup";

  config = lib.mkIf cfg.enable {
    suites.editors.vscode.enable = true;
    programs.vscode.profiles.default = {
      extensions =
        with pkgs.vscode-extensions;
        [
          # Additional language support.
          bbenoist.nix
          graphql.vscode-graphql
          ms-azuretools.vscode-docker
          ms-vscode.cmake-tools
          ms-vscode.cpptools
          ms-vscode.powershell

          # Extra editor niceties.
          eamodio.gitlens
          mkhl.direnv
          usernamehw.errorlens
          vadimcn.vscode-lldb

          # The other niceties.
          editorconfig.editorconfig
          alefragnani.project-manager
          fill-labs.dependi
        ]
        ++ lib.optionals userCfg.programs.browsers.firefox.enable [ firefox-devtools.vscode-firefox-debug ]
        ++ lib.optionals config.programs.python.enable [
          ms-toolsai.jupyter
          ms-toolsai.jupyter-renderers
        ]
        ++ lib.optionals userCfg.setups.research.writing.enable [ ltex-plus.vscode-ltex-plus ]
        ++ lib.optionals attrs.nixosConfig.suites.dev.containers.enable or false [
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode-remote.remote-containers
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              publisher = "ms-vscode";
              name = "remote-server";
              version = "1.5.3";
              hash = "sha256-MSayIBwvSgIHg6gTrtUotHznvo5kTiveN8iSrehllW0=";
            };
          })
        ]
        ++ lib.optionals userCfg.setups.development.creative-coding.enable [
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              publisher = "tidalcycles";
              name = "vscode-tidalcycles";
              version = "2.0.2";
              hash = "sha256-TfRLJZcMpoBJuXitbRmacbglJABZrMGtSNXAbjSfLaQ=";
            };
          })
        ];

      userSettings = lib.mkMerge [
        {
          "extensions.ignoreRecommendations" = true;
        }

        (lib.mkIf attrs.nixosConfig.suites.dev.containers.enable or false {
          "dev.containers.dockerPath" = "podman";
        })
      ];
    };

    # We're using Visual Studio Code as a git difftool and mergetool which is
    # surprisingly good compared to the competition (which is not much).
    programs.git.settings = {
      diff.tool = lib.mkDefault "vscode";
      difftool.vscode.cmd = "code --wait --diff $LOCAL $REMOTE";

      # It has a three-way merge.
      merge.tool = lib.mkDefault "vscode";
      mergetool.vscode.cmd = "code --wait --merge $REMOTE $LOCAL $BASE $MERGED";
    };
  };
}
