# SPDX-FileCopyrightText: 2024-2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  pkgs,
  foodogsquaredLib,
  ...
}:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.setups.business;
in
{
  options.users.foo-dogsquared.setups.business.enable = lib.mkEnableOption "business setup";

  config = lib.mkIf cfg.enable {
    users.foo-dogsquared.programs = {
      email = {
        enable = true;
        thunderbird.enable = true;
      };
    };

    home.packages = with pkgs; [
      libreoffice
    ];

    wrapper-manager.packages.web-apps = lib.mkIf userCfg.programs.browsers.google-chrome.enable (
      {
        hmConfig,
        config,
        foodogsquaredLib,
        ...
      }:
      {
        programs.chromium-web-apps.apps = {
          google-workspace = {
            baseURL = "workspace.google.com";
            imageHash = "sha512-fdbTvnDTU7DQLSGth8hcsnTNWnBK1qc8Rvmak4oaOE+35YTJ9G8q+BdTqoYxUBxq9Dv9TkAB8Vu7UKjZL1GMcQ==";
            flags = foodogsquaredLib.extra.mkCommonChromiumFlags "google-workspace";
            desktopEntrySettings = {
              desktopName = "Google Workspace";
              genericName = "Cloud Software Suite";
              comment = "Collection of Google cloud tools";
              keywords = [
                "Microsoft 365"
                "Google Docs"
                "Google Drive"
                "Google Calendar"
                "Google Sheets"
                "Gmail"
              ];
            };
          };

          microsoft-teams = {
            baseURL = "teams.microsoft.com";
            imageHash = "sha512-p71hFz3xGNCThfzgA00icEpmH8XKeRHLxwIwDruiixBmwFa/LbCkzwrkXZS4xntPrysObCsM7L0vvWl6Iq1ZAA==";
            flags = foodogsquaredLib.extra.mkCommonChromiumFlags "microsoft-teams";
            desktopEntrySettings = {
              desktopName = "Microsoft Teams";
              genericName = "Video Conferencing";
              comment = "Video conferencing software";
              keywords = [
                "Zoom"
                "Jitsi"
                "Work Chat"
              ];
            };
          };

          messenger = {
            baseURL = "www.messenger.com";
            imageHash = "sha512-3rbCuiW14TVu8G+VU7hEDsmW4Q7XTx6ZLeEeFtY3XUB9ylzkNSJPwz6U8EiA5vOF1f6qeO4RVWVi8n5jibPouQ==";
            flags = foodogsquaredLib.extra.mkCommonChromiumFlags "messenger";
            desktopEntrySettings = {
              desktopName = "Messenger";
              genericName = "Instant Messaging Client";
              comment = "Instant messaging network";
              keywords = [
                "Facebook Messenger"
                "Meta Messenger"
                "Chat"
              ];
              mimeTypes = [ "x-scheme-handler/fb-messenger" ];
            };
          };

          discord = {
            baseURL = "app.discord.com";
            imageHash = "sha512-A3HStENdfTG1IA5j5nCebKmQkJaKIC5Rp2NGt0ba/a3aUriVrBFZYcYmLmwDY8F98zCKyazBvnCGz9Z5/yfvUw==";
            imageFetcherArgs = [
              "--disable-html-download"
            ];
            flags = foodogsquaredLib.extra.mkCommonChromiumFlags "discord";
            desktopEntrySettings = {
              desktopName = "Discord";
              genericName = "Group Messaging Client";
              comment = "Group text and voice messaging";
              keywords = [
                "Chat"
                "Instant Messaging"
                "Video Conferencing"
                "Video Calls"
                "Audio Calls"
              ];
              mimeTypes = [ "x-scheme-handler/discord" ];
            };
          };

          zoom = {
            baseURL = "zoom.us";
            imageHash = "sha512-l0XEVskMHJXBEdqqZBkDTgGp+F50ux22d1KHH63/Bu83awQP4v80/p3Csuiz4IfIowEu27nucDkIg/nmLotvhQ==";
            flags = foodogsquaredLib.extra.mkCommonChromiumFlags "zoom";
            desktopEntrySettings = {
              desktopName = "Zoom";
              genericName = "Video Conferencing";
              comment = "Video conferencing";
              keywords = [
                "Audio Calls"
                "Video Calls"
                "Work Chat"
              ];
            };
          };
        };
      }
    );
  };
}
