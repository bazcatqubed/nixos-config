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
  cfg = config.subenvironments;

  subenvModule =
    { name, ... }:
    {
      options = {
        paths = lib.mkOption {
          description = ''
            List of packages to be included within the given environment.
          '';
          type = with lib.types; listOf package;
          default = [ ];
          example = lib.literalExpression ''
            with pkgs; [
              hello
              gcc
            ]
          '';
        };

        pathsToLink = lib.mkOption {
          description = ''
            List of paths to be included per-path within the environment. By
            default, it should include everything.
          '';
          type = with lib.types; listOf str;
          default = [ "/" ];
          example = [
            "/man"
            "/bin"
          ];
        };

        extraOutputsToInstall = lib.mkOption {
          description = ''
            List of extra outputs per-path given from `paths`.
          '';
          type = with lib.types; listOf str;
          default = [ ];
          example = [
            "man"
            "dev"
          ];
        };

        profileRelativeEnvVars = lib.mkOption {
          description = ''
            Set of environment variables to be mapped to the environment.
          '';
          type = with lib.types; attrsOf (listOf str);
          default = { };
          example = {
            MANPATH = [
              "/man"
              "/share/man"
            ];

            PATH = [
              "/bin"
            ];
          };
        };
      };
    };
in
{
  options.subenvironments = lib.mkOption {
    type = with lib.types; attrsOf (submodule subenvModule);
    default = { };
    description = ''
      A set of subenvironments.
    '';
  };

  config = lib.mkIf (cfg != { }) {
    basePackages =
      let
        exportEnvVars =
          envvars:
          lib.mapAttrsToList (
            n: v:
            let
              v' = if lib.isList v then lib.concatStringsSep ":" v else toString v;
            in
            ''
              export ${lib.escapeShellArg n}=${lib.escapeShellArg v'}
            ''
          ) envvars;

        mkBuildEnv =
          n: v:
          pkgs.buildEnv {
            name = "wrapper-manager-subenv-${n}";
            inherit (v) pathsToLink extraOutputsToInstall;
            paths =
              v.paths
              ++ lib.optionals (v.profileRelativeEnvVars != { }) [
                (pkgs.writeTextDir "/etc/profile" (exportEnvVars v.profileRelativeEnvVars))
              ];
          };
      in
      lib.mapAttrsToList mkBuildEnv cfg;
  };
}
