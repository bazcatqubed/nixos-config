# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# All of the development-related shtick for this project is over here.
{ inputs, ... }:
{
  flake = {
    foodogsquaredLib = ../../lib;
  };

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      devshell = import ../../shell.nix { inherit pkgs; };
    in
    {
      apps = {
        run-workflow-with-vm =
          let
            inputsArgs = lib.mapAttrsToList (
              name: source:
              let
                name' = if (name == "self") then "config" else name;
              in
              "'${name'}=${source}'"
            ) inputs;
            script = pkgs.callPackage ../../apps/run-workflow-with-vm {
              inputs = inputsArgs;
            };
          in
          {
            meta.description = "Easily instantiate virtual machines with the given workflow for debugging your DEs";
            type = "app";
            program = "${script}/bin/run-workflow-with-vm";
          };

        ffof = {
          meta.description = "Fetch a bunch of things that built-in Nix fetchers cannot";
          type = "app";
          program =
            let
              package = pkgs.callPackage ../../apps/fds-fetcher-flock/nix/package.nix { };
            in
            lib.getExe package;
        };
      };

      checks.reuse-compliance =
        pkgs.runCommand "reuse-compliance-check"
          {
            buildInputs = with pkgs; [ reuse ];
          }
          ''
            (
              cd ${inputs.self}
              reuse lint
            ) && touch $out
          '';

      # No amount of formatters will make this codebase nicer but it sure does
      # feel like it does.
      formatter = pkgs.treefmt;

      # My several development shells for usual type of projects. This is much
      # more preferable than installing all of the packages at the system
      # configuration (or even home environment).
      devShells = lib.mkMerge [
        (import ../../shells { inherit pkgs; })

        {
          default = import ../../shell.nix {
            inherit pkgs;
            extraPackages = with pkgs; [
              # Mozilla addons-specific tooling. Unfortunately, only available with
              # flakes-based setups.
              nur.repos.rycee.mozilla-addons-to-nix
            ];
          };
          website = import ../../docs/website/shell.nix { inherit pkgs; };
        }
      ];

      # Packages that are meant to be consumed inside of a development
      # environment.
      devPackages = {
        inherit (import ../../docs { inherit pkgs; }) website;
        foodogsquared-homepage =
          pkgs.callPackage ../../configs/home-manager/foo-dogsquared/files/homepage/package.nix
            { };
      };

      # All of the typical devcontainers to be used.
      devContainers = import ../../devcontainers { inherit pkgs; };
    };
}
