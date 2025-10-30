# Take note, this already assumes we're using on top of an already existing
# NixVim configuration. See the declarative users configuration for more
# details.
{ config, lib, pkgs, firstSetupArgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.nixvim;
  hmCfg = config;

  createNixvimFlavor = module:
    pkgs.nixvim.makeNixvimWithModule {
      inherit pkgs;
      module.imports = firstSetupArgs.baseNixvimModules ++ [ module ];
      extraSpecialArgs.hmConfig = config;
    };

  # The main NixVim flavor and also where the extra files in the environment
  # will come from.
  nvimPkg = createNixvimFlavor ({ config, ... }: {
    imports = [
      ./colorschemes.nix
      ./fuzzy-finding.nix
      ./misc.nix
      ./note-taking.nix
      ./dev.nix
      ./lsp.nix
      ./dap.nix
      ./qol.nix
    ];

    config = {
      nixvimConfigs.fiesta-fds.setups = {
        colorschemes.enable = true;
        fuzzy-finding.enable = true;
        note-taking.enable = true;
        qol.enable = true;
        misc.enable = true;
        dev.enable = userCfg.setups.development.enable;
        lsp.enable = userCfg.setups.development.enable;
        dap.enable = userCfg.setups.development.enable;
      };

      # Inherit all of the schemes.
      bahaghari.tinted-theming.schemes =
        hmCfg.bahaghari.tinted-theming.schemes;

      # Install ALL OF THEM tree-sitter grammers instead.
      plugins.treesitter.grammarPackages =
        lib.mkForce config.plugins.treesitter.package.passthru.allGrammars;
    };
  });

  nixvimManpage = pkgs.runCommand "get-main-nixvim-manpage" { } ''
    mkdir -p $out/share && cp -r "${nvimPkg}/share/man" $out/share
  '';

  neovimFlavorsPackage = config.wrapper-manager.packages.neovim-flavors.build.toplevel;
in {
  options.users.foo-dogsquared.programs.nixvim.enable =
    lib.mkEnableOption "editors made with NixVim";

  config = lib.mkIf cfg.enable {
    state.ports.neovim-fiesta-remote-server.value = 9099;

    state.packages.editor = lib.mkForce nvimPkg;

    home.packages = [ nixvimManpage ];

    # Basically, we're creating Neovim flavors with NixVim so no need for it.
    wrapper-manager.packages.neovim-flavors = { config, ... }: let
      exeName = config.wrappers.nvim-fiesta-fds.executableName;
    in {
      build.extraMeta.mainProgram = exeName;

      wrappers.nvim-fiesta-fds = {
        arg0 = lib.getExe' nvimPkg "nvim";
        xdg.desktopEntry = {
          enable = true;
          settings = {
            desktopName = "Neovim (nvim-fiesta-fds)";
            tryExec = exeName;
            exec = lib.mkForce "${exeName} %F";
            terminal = true;
            categories = [ "Utility" "TextEditor" ];
            icon = "nvim";
            comment = "Edit text files with nvim-fiesta-fds configuration";
            genericName = "Text Editor";
            mimeTypes = [ "text/plain" ];
          };
        };
      };
    };

    systemd.user.services.neovim-fiesta-remote-server = {
      Unit = {
        Description = "Neovim (nvim-fiesta-fds) headless server";
        Documentation = [
          "man:nvim(1)"
        ];
      };

      Service = {
        ExecStart = let
          port = config.state.ports.neovim-fiesta-remote-server.value;
        in ''
          ${lib.getExe' neovimFlavorsPackage "nvim-fiesta-fds"} --headless --listen 0.0.0.0:${builtins.toString port}
        '';
        Restart = "always";
        RestartSec = 12;
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
