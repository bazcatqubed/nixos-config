# SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

# Yeaaaaaah... We're going here. Anyways, I'm mostly using the chat interface
# solely as a fuzzier search engine. Not so much AI coding in the terminal yet
# but who knows... Still don't trust them for basic coding tasks for the most
# part.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.ai;
in
{
  options.users.foo-dogsquared.setups.ai.enable =
    lib.mkEnableOption "installation of AI-related tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aider-chat-full # Invite an uninviting robot in your programming session.
      plandex # Roleplay/train your senior role by training a junior to fuck up your project.
    ];

    # Now see them robits with a graphical app.
    programs.newelle.enable = true;

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
    };
  };
}
