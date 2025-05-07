{ config, lib, pkgs, ... }:

let
  userCfg = config.users.foo-dogsquared;
  cfg = userCfg.programs.email;

  mkEmailAccount = { domain ? "foodogsquared.one", name }: {
    address = "${name}@${domain}";
    userName = "${name}@${domain}";
    realName = lib.mkDefault "${name}@${domain}";
    passwordCommand =
      lib.mkDefault "gopass show email/${domain}/${name} | head -n 1";

    imap = {
      host = "heracles.mxrouting.net";
      port = 993;
      tls.enable = true;
    };

    # Set up the outgoing mails.
    smtp = {
      host = "heracles.mxrouting.net";
      port = 465;
      tls.enable = true;
    };
  };
in {
  options.users.foo-dogsquared.programs.email = {
    enable = lib.mkEnableOption "foo-dogsquared's email setup";
    thunderbird.enable =
      lib.mkEnableOption "foo-dogsquared's Thunderbird configuration";
    himalaya.enable =
      lib.mkEnableOption "foo-dogsquared's email client on the command line";
    aerc.enable =
      lib.mkEnableOption "foo-dogsquared's TUI email client";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      accounts.email.accounts = {
        # TODO: Enable offlineimap once maildir support is stable in Thunderbird.
        work = lib.mkMerge [
          (mkEmailAccount { name = "foodogsquared"; })

          {
            primary = true;
            realName = "Gabriel Arazas";
            signature = {
              delimiter = "--<----<---->---->--";
              text = ''
                foodogsquared at foodogsquared dot one
              '';
            };

            # GPG settings... wablamo.
            gpg = {
              key = "0xADE0C41DAB221FCC";
              encryptByDefault = false;
              signByDefault = false;
            };
          }
        ];

        personal = lib.mkMerge [
          (mkEmailAccount { name = "__personal__"; })

          {
            realName = "Gabriel Arazas";
            signature = {
              delimiter = "--<----<---->---->--";
              text = "HEYHEYComeOnOverAndHaveFunWithSomeCRAZYTAXI";
            };
          }
        ];

        postmaster = mkEmailAccount { name = "postmaster"; };
        webmaster = mkEmailAccount { name = "webmaster"; };

        old_work = {
          address = "foo.dogsquared@gmail.com";
          realName = config.accounts.email.accounts.personal.realName;
          userName = "foo.dogsquared@gmail.com";
          flavor = "gmail.com";
          passwordCommand =
            "gopass show websites/accounts.google.com/foo.dogsquared | head -n 1";
        };
      };
    }

    (lib.mkIf cfg.thunderbird.enable {
      home.packages = lib.singleton pkgs.thunderbird-foodogsquared;

      accounts.email.accounts =
        let
          enabledEmails = [
            "personal"
            "work"
            "old_work"
          ];
          enableThunderbirdAccount = name: { thunderbird.enable = true; };
        in
        lib.genAttrs enabledEmails enableThunderbirdAccount;

      programs.thunderbird = {
        # enable = true;
        package = pkgs.thunderbird-foodogsquared;
        profiles.personal = {
          isDefault = true;
          settings = {
            "mail.identity.default.archive_enabled" = true;
            "mail.identity.default.archive_keep_folder_structure" = true;
            "mail.identity.default.compose_html" = false;
            "mail.identity.default.protectSubject" = true;
            "mail.identity.default.reply_on_top" = 1;
            "mail.identity.default.sig_on_reply" = true;

            "mail.server.default.canDelete" = true;
          };

          feedAccounts = {
            "Project activities" = { };
            "Blogs and articles" = { };
          };
        };

        settings = {
          # Some general settings.
          "mail.server.default.allow_utf8_accept" = true;
          "mail.server.default.max_articles" = 1000;
          "mail.server.default.check_all_folders_for_new" = true;
          "mail.show_headers" = 1;

          # Show some metadata.
          "mailnews.headers.showMessageId" = true;
          "mailnews.headers.showOrganization" = true;
          "mailnews.headers.showReferences" = true;
          "mailnews.headers.showUserAgent" = true;

          # Sort mails and news in descending order.
          "mailnews.default_sort_order" = 2;
          "mailnews.default_news_sort_order" = 2;

          # Sort mails and news by date.
          "mailnews.default_sort_type" = 18;
          "mailnews.default_news_sort_type" = 18;

          # Sort them by the newest reply in thread.
          "mailnews.sort_threads_by_root" = true;

          # Show time. :)
          "mail.ui.display.dateformat.default" = 1;

          # Sanitize it to UTC to prevent leaking local time.
          "mail.sanitize_date_header" = true;

          # Trust positives from server spam filter.
          "mail.server.default.serverFilterName" = "SpamAssassin";
          "mail.server.default.serverFilterFlags" = 1;

          # Email composing QoL.
          "mail.identity.default.auto_quote" = true;
          "mail.identity.default.attachPgpKey" = true;

          # RSS feeds options.
          "rss.max_concurrent_feeds" = 30;
          "rss.disable_feeds_on_update_failure" = false;

          # Open web page on default browser on select.
          "rss.message.loadWebPageOnSelect" = 0;

          # Load the summary on display.
          "rss.show.summary" = 1;

          # Open the web page on new window.
          "rss.show.content-base" = 0;

          # Don't tease me with the updates, man.
          "app.update.auto" = false;

          "privacy.donottrackheader.enabled" = true;
        };
      };

      services.bleachbit.cleaners = [
        "thunderbird.cache"
        "thunderbird.cookies"
        "thunderbird.index"
        "thunderbird.passwords"
        "thunderbird.sessionjson"
        "thunderbird.vacuum"
      ];
    })

    (lib.mkIf cfg.himalaya.enable {
      accounts.email.accounts =
        let
          enabledEmails = [
            "personal"
            "work"
            "old_work"
          ];

          mkEmailAccount = name: { himalaya.enable = true; };
        in
        lib.genAttrs enabledEmails mkEmailAccount;

      programs.himalaya = {
        enable = true;
        settings = {
          signature-delim = "-- \n";
          downloads-dir = config.xdg.userDirs.download;
        };
      };
    })

    (lib.mkIf cfg.aerc.enable {
      accounts.email.accounts =
        let
          enabledEmails = [
            "personal"
            "work"
            "old_work"
          ];

          mkEmailAccount = name: { aerc.enable = true; };
        in
        lib.genAttrs enabledEmails mkEmailAccount;

      programs.aerc = {
        enable = true;
        extraConfig = {
          general = {
            default-save-path = config.xdg.userDirs.download;
            unsafe-accounts-conf = true;
            enable-osc8 = userCfg.setups.development.enable;
          };

          viewer.pager = config.systemd.user.sessionVariables.PAGER;

          ui = {
            fuzzy-complete = true;
            empty-subject = "[EMPTY SUBJECT]";
            empty-message = "[EMPTY MESSAGE]";
            mouse-enabled = true;
          };

          compose = {
            empty-subject-warning = true;
            focus-body = true;
          };
        };
      };
    })
  ]);
}
