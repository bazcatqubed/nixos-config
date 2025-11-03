default:
    just --list

# Update the flake lockfile.
update:
    git checkout -- flake.lock
    nix flake update --commit-lock-file

# Quickly inspect a NixOS configuration.
object-inspect HOST ATTR="nixosConfigurations" *ARGS:
    nix repl '.#{{ATTR}}.{{HOST}}-{{arch()}}-{{os()}}' {{ARGS}}

# Small wrapper around nixos-rebuild.
host-build HOST *ARGS:
    nixos-rebuild --flake '.#{{HOST}}-{{arch()}}-{{os()}}' {{ARGS}}

# Gives the diff between the current installed system and the to-be-built version of the system.
host-diff HOST *ARGS:
    nixos-rebuild build --flake ".#{{HOST}}-{{arch()}}-{{os()}}" {{ARGS}} && nvd diff /run/current-system result

# Small wrapper for installing NixOS systems.
nixos-install HOST *ARGS:
    disko-install --flake '.#{{HOST}}-{{arch()}}-{{os()}}' {{ARGS}}

# Update a package with nix-update.
pkg-update PKG *ARGS:
    nix-update -f pkgs {{PKG}} {{ARGS}}

# Build a package from `pkgs/` folder.
pkg-build PKG *ARGS:
    nix-build pkgs -A {{PKG}} {{ARGS}}

# Build Firefox addons.
pkg-build-firefox-addons:
    mozilla-addons-to-nix ./pkgs/firefox-addons/firefox-addons.json ./pkgs/firefox-addons/default.nix

# Live server for project website.
docs-serve:
    hugo -s ./docs serve

# Build the project website.
docs-build:
    hugo -s ./docs/

# Deploy NixOS system.
deploy-nixos HOST *ARGS:
    deploy '.#nixos-{{HOST}}' --skip-checks {{ARGS}}

# Deploy home environment.
deploy-hm USER *ARGS:
    deploy '.#home-manager-{{USER}}' --skip-checks {{ARGS}}

# Build NixVim configurations.
nixvim-build INSTANCE *ARGS:
    nix build .#nixvimConfigurations.{{arch()}}.{{INSTANCE}} {{ARGS}}

# Run NixVim configurations.
nixvim-run INSTANCE *ARGS:
    nix run .#nixvimConfigurations.{{arch()}}.{{INSTANCE}} {{ARGS}}
