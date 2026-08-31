{ buildMozillaXpiAddon, fetchurl, lib, stdenv }:
  {
    "cookies-txt" = buildMozillaXpiAddon {
      pname = "cookies-txt";
      version = "1.0";
      addonId = "{12cf650b-1822-40aa-bff0-996df6948878}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4624727/cookies_txt-1.0.xpi";
      sha256 = "5277a747488f2bbe657e83f8266eb7f7d3c30aeb886be53b9de87766f2053406";
      meta = with lib;
      {
        description = "Exports all cookies to a Netscape HTTP Cookie File, as used by curl, wget, and youtube-dl, among others.";
        license = licenses.gpl3;
        mozPermissions = [
          "cookies"
          "downloads"
          "contextualIdentities"
          "<all_urls>"
          "tabs"
          "clipboardWrite"
        ];
        platforms = platforms.all;
      };
    };
    "dearrow" = buildMozillaXpiAddon {
      pname = "dearrow";
      version = "2.3.10";
      addonId = "deArrow@ajay.app";
      url = "https://addons.mozilla.org/firefox/downloads/file/4897568/dearrow-2.3.10.xpi";
      sha256 = "3151a51db8093746be646c041af3ead553e5de95fa4ebd5fae033e039e1056d1";
      meta = with lib;
      {
        homepage = "https://dearrow.ajay.app";
        description = "Crowdsourcing titles and thumbnails to be descriptive and not sensational";
        license = licenses.lgpl3;
        mozPermissions = [
          "storage"
          "unlimitedStorage"
          "alarms"
          "https://sponsor.ajay.app/*"
          "https://dearrow-thumb.ajay.app/*"
          "https://*.googlevideo.com/*"
          "https://*.youtube.com/*"
          "https://www.youtube-nocookie.com/embed/*"
          "scripting"
          "https://dearrow.ajay.app/*"
        ];
        platforms = platforms.all;
      };
    };
    "extended-color-management" = buildMozillaXpiAddon {
      pname = "extended-color-management";
      version = "1.1.2";
      addonId = "{816dd215-0e91-4621-9d89-3bac78798e6f}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4581050/extended_color_management-1.1.2.xpi";
      sha256 = "3b877b0f8425031fd73adc940b9439fc0847301d5f1cb7947ae9f6957eb56642";
      meta = with lib;
      {
        description = "Ever wish that Firefox didn't use color management when viewing images or video? Turn it off easily with this add-on.";
        license = licenses.mpl20;
        mozPermissions = [
          "browserSettings"
          "notifications"
          "storage"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "font-inspect" = buildMozillaXpiAddon {
      pname = "font-inspect";
      version = "0.6.5";
      addonId = "{a658a273-612e-489e-b4f1-5344e672f4f5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4752199/font_inspect-0.6.5.xpi";
      sha256 = "f6af6b2fcbf5dc9a9afd026174ac6e8340659e408a4e326da9bc048ec1b41f8d";
      meta = with lib;
      {
        homepage = "https://webextension.org/listing/font-finder.html";
        description = "An easy-to-use font inspector to get CSS styles of the selected element";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "contextMenus"
          "notifications"
          "scripting"
          "activeTab"
        ];
        platforms = platforms.all;
      };
    };
    "get-rss-feed-url" = buildMozillaXpiAddon {
      pname = "get-rss-feed-url";
      version = "2.2";
      addonId = "{15bdb1ce-fa9d-4a00-b859-66c214263ac0}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3990496/get_rss_feed_url-2.2.xpi";
      sha256 = "c332726405c6e976b19fc41bfb3ce70fa4380aaf33f179f324b67cb6fc13b7d0";
      meta = with lib;
      {
        homepage = "https://github.com/shevabam/get-rss-feed-url-extension";
        description = "Retrieve RSS feeds URLs from a WebSite. Now in Firefox!";
        license = licenses.mit;
        mozPermissions = [
          "http://*/*"
          "https://*/*"
          "notifications"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "google-container" = buildMozillaXpiAddon {
      pname = "google-container";
      version = "1.5.4";
      addonId = "@contain-google";
      url = "https://addons.mozilla.org/firefox/downloads/file/3736912/google_container-1.5.4.xpi";
      sha256 = "47a7c0e85468332a0d949928d8b74376192cde4abaa14280002b3aca4ec814d0";
      meta = with lib;
      {
        homepage = "https://github.com/containers-everywhere/contain-google";
        description = "THIS IS NOT AN OFFICIAL ADDON FROM MOZILLA!\nIt is a fork of the Facebook Container addon.\n\nPrevent Google from tracking you around the web. The Google Container extension helps you take control and isolate your web activity from Google.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "contextualIdentities"
          "cookies"
          "management"
          "tabs"
          "webRequestBlocking"
          "webRequest"
          "storage"
        ];
        platforms = platforms.all;
      };
    };
    "gopass-bridge" = buildMozillaXpiAddon {
      pname = "gopass-bridge";
      version = "2.1.1";
      addonId = "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4630675/gopass_bridge-2.1.1.xpi";
      sha256 = "e8ac742baf8fd9954672b778440acf9d87666d93df470d8d7be53e2cb051141f";
      meta = with lib;
      {
        homepage = "https://github.com/gopasspw/gopassbridge";
        description = "Gopass Bridge allows searching, inserting and managing login credentials from the gopass password manager.";
        license = licenses.mit;
        mozPermissions = [
          "<all_urls>"
          "activeTab"
          "clipboardWrite"
          "storage"
          "nativeMessaging"
          "notifications"
          "webRequest"
          "webRequestBlocking"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "indie-wiki-buddy" = buildMozillaXpiAddon {
      pname = "indie-wiki-buddy";
      version = "4.0.0";
      addonId = "{cb31ec5d-c49a-4e5a-b240-16c767444f62}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4982796/indie_wiki_buddy-4.0.0.xpi";
      sha256 = "2769ffe55ff3462eef9029f00d90bb2df7d3f2fa6521b90de47aa81152e25df8";
      meta = with lib;
      {
        homepage = "https://getindie.wiki/";
        description = "Helping you discover quality, independent wikis!\n\nWhen visiting a Fandom wiki, Indie Wiki Buddy redirects or alerts you of independent alternatives. It also filters search engine results. BreezeWiki is also supported, to reduce clutter on Fandom.";
        license = licenses.mit;
        mozPermissions = [
          "alarms"
          "storage"
          "webRequest"
          "notifications"
          "scripting"
          "https://*.fandom.com/*"
          "https://*.fextralife.com/*"
          "https://*.neoseeker.com/*"
          "https://breezewiki.com/*"
          "https://www.google.com/search*"
        ];
        platforms = platforms.all;
      };
    };
    "microsoft-container" = buildMozillaXpiAddon {
      pname = "microsoft-container";
      version = "1.0.4";
      addonId = "@contain-microsoft";
      url = "https://addons.mozilla.org/firefox/downloads/file/3711415/microsoft_container-1.0.4.xpi";
      sha256 = "8780c9edcfa77a9f3eaa7da228a351400c42a884fec732cafc316e07f55018d3";
      meta = with lib;
      {
        homepage = "https://github.com/kouassi-goli/contain-microsoft";
        description = "This add-on is an unofficial fork of Mozilla's Facebook Container designed for Microsoft. \n Microsoft Container isolates your Microsoft activity from the rest of your web activity and prevent Microsoft from tracking you outside of the its website.";
        license = licenses.mpl20;
        mozPermissions = [
          "<all_urls>"
          "contextualIdentities"
          "cookies"
          "management"
          "tabs"
          "webRequestBlocking"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "open-access-helper" = buildMozillaXpiAddon {
      pname = "open-access-helper";
      version = "2026.8";
      addonId = "info@oahelper.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4972994/open_access_helper-2026.8.xpi";
      sha256 = "1ae2bd20c7eaa845bf5f15bab0af5ccf6931184caa74a6576a71324b80b7d447";
      meta = with lib;
      {
        homepage = "https://www.oahelper.org";
        description = "Effortless legal access to full text scholarly articles: \nOpen Access Helper will help you identify legal open access copies of academic articles, using unpaywall.org and other sources.";
        mozPermissions = [
          "tabs"
          "storage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "*://*/*"
          "https://www.oahelper.org/backend/institutes/"
        ];
        platforms = platforms.all;
      };
    };
    "open-in-visual-studio-code" = buildMozillaXpiAddon {
      pname = "open-in-visual-studio-code";
      version = "1.0.2";
      addonId = "{90404617-2d7e-4bde-9d55-e9eda31ca5b3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4010707/open_in_visual_studio_code-1.0.2.xpi";
      sha256 = "8112606071800fef4e47472cab302b645546102b547132a37557a39be9da510b";
      meta = with lib;
      {
        description = "Adds an \"Open in Visual Studio Code\" button to GitHub repos";
        license = licenses.mit;
        mozPermissions = [ "*://github.com/*" ];
        platforms = platforms.all;
      };
    };
    "private-grammar-checker-harper" = buildMozillaXpiAddon {
      pname = "private-grammar-checker-harper";
      version = "2.8.0";
      addonId = "harper@writewithharper.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4957307/private_grammar_checker_harper-2.8.0.xpi";
      sha256 = "89b924ea7a260eb98f2ab69aa50ff77ac3750b3c1f8aaca7b674b829ff1a71ea";
      meta = with lib;
      {
        homepage = "https://writewithharper.com";
        description = "A private grammar checker for 21st Century English";
        mozPermissions = [
          "storage"
          "tabs"
          "https://docs.google.com/document/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "refined-github-" = buildMozillaXpiAddon {
      pname = "refined-github-";
      version = "26.8.8";
      addonId = "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4945591/refined_github-26.8.8.xpi";
      sha256 = "cfa6508a75193560a2623220a4e59c6bad7099fed16d65e04c28f0372775e4c6";
      meta = with lib;
      {
        homepage = "https://github.com/refined-github/refined-github";
        description = "Simplifies the GitHub interface and adds many useful features.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "scripting"
          "contextMenus"
          "activeTab"
          "alarms"
          "https://github.com/*"
          "https://gist.github.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "regretsreporter" = buildMozillaXpiAddon {
      pname = "regretsreporter";
      version = "2.1.2";
      addonId = "regrets-reporter@mozillafoundation.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4049907/regretsreporter-2.1.2.xpi";
      sha256 = "6916bcba2c479b209510509aca304f35cf68bafbdde852511a98e501c99e77e0";
      meta = with lib;
      {
        homepage = "https://foundation.mozilla.org/regrets-reporter";
        description = "The RegretsReporter browser extension, built by the nonprofit Mozilla, helps you take control of your YouTube recommendations.";
        license = licenses.mpl20;
        mozPermissions = [
          "*://*.youtube.com/*"
          "https://incoming.telemetry.mozilla.org/*"
          "storage"
          "alarms"
          "webRequest"
        ];
        platforms = platforms.all;
      };
    };
    "rsshub-radar" = buildMozillaXpiAddon {
      pname = "rsshub-radar";
      version = "1.10.3";
      addonId = "i@diygod.me";
      url = "https://addons.mozilla.org/firefox/downloads/file/4197124/rsshub_radar-1.10.3.xpi";
      sha256 = "66a2aec4f67e27dd6a4a768ee8e87b3b321bac5385e3241b1664b95aae25077d";
      meta = with lib;
      {
        homepage = "https://github.com/DIYgod/RSSHub-Radar";
        description = "Easily find and subscribe to RSS and RSSHub.";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "storage"
          "notifications"
          "alarms"
          "idle"
          "https://*/*"
          "http://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "simple-translate" = buildMozillaXpiAddon {
      pname = "simple-translate";
      version = "3.1.0";
      addonId = "simple-translate@sienori";
      url = "https://addons.mozilla.org/firefox/downloads/file/4979122/simple_translate-3.1.0.xpi";
      sha256 = "c27591eae7363fb0635f21277ac4e0bc5709e6cff299d33bec4de8106c298951";
      meta = with lib;
      {
        homepage = "https://simple-translate.sienori.com";
        description = "Quickly translate selected or typed text on web pages. Supports Google Translate and DeepL API.";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "contextMenus"
          "http://*/*"
          "https://*/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "sourcegraph-for-firefox" = buildMozillaXpiAddon {
      pname = "sourcegraph-for-firefox";
      version = "23.4.14.1343";
      addonId = "sourcegraph-for-firefox@sourcegraph.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4097469/sourcegraph_for_firefox-23.4.14.1343.xpi";
      sha256 = "fa02236d75a82a7c47dabd0272b77dd9a74e8069563415a7b8b2b9d37c36d20b";
      meta = with lib;
      {
        description = "Adds code intelligence to GitHub, GitLab, Bitbucket Server, and Phabricator: hovers, definitions, references. Supports 20+ languages.";
        mozPermissions = [
          "activeTab"
          "storage"
          "contextMenus"
          "https://github.com/*"
          "https://sourcegraph.com/*"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
    "tineye-reverse-image-search" = buildMozillaXpiAddon {
      pname = "tineye-reverse-image-search";
      version = "2.0.9";
      addonId = "tineye@ideeinc.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4452436/tineye_reverse_image_search-2.0.9.xpi";
      sha256 = "6693b267ca060df38112b3a7214932abfbd07424f7db235eba6e3752cbd5c297";
      meta = with lib;
      {
        homepage = "https://tineye.com/";
        description = "Click on any image on the web to search for it on TinEye. Recommended by Firefox! \r\nDiscover where an image came from, see how it is being used, check if modified versions exist or locate high resolution versions. Made with love by the TinEye team.";
        license = licenses.mit;
        mozPermissions = [ "menus" "storage" "scripting" "activeTab" ];
        platforms = platforms.all;
      };
    };
    "tor-control" = buildMozillaXpiAddon {
      pname = "tor-control";
      version = "0.1.5";
      addonId = "{d22a1484-dcef-44e9-ab52-80f0f4a331a3}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3698582/tor_control-0.1.5.xpi";
      sha256 = "3b529ee8993e1bdb374bb8f1fb926564eb10cd4403c09bc55077a0b72f6ff937";
      meta = with lib;
      {
        homepage = "https://add0n.com/tor-control.html";
        description = "Brings the anonymity of the Tor network and modifies few settings to protect user privacy";
        license = licenses.mpl20;
        mozPermissions = [
          "storage"
          "proxy"
          "privacy"
          "notifications"
          "nativeMessaging"
        ];
        platforms = platforms.all;
      };
    };
    "unpaywall" = buildMozillaXpiAddon {
      pname = "unpaywall";
      version = "3.98";
      addonId = "{f209234a-76f0-4735-9920-eb62507a54cd}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3816853/unpaywall-3.98.xpi";
      sha256 = "6893bea86d3c4ed7f1100bf0e173591b526a062f4ddd7be13c30a54573c797fb";
      meta = with lib;
      {
        homepage = "https://unpaywall.org/products/extension";
        description = "Get free text of research papers as you browse, using Unpaywall's index of ten million legal, open-access articles.";
        license = licenses.mit;
        mozPermissions = [ "*://*.oadoi.org/*" "storage" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
    "updateswh" = buildMozillaXpiAddon {
      pname = "updateswh";
      version = "0.9.2";
      addonId = "{157eb9f0-9814-4fcc-b0b7-586b3093c641}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4836256/updateswh-0.9.2.xpi";
      sha256 = "db33f60b9a02539d061c2678f9defdcbc02a8e6a241678e9510f7b4895cb5a3b";
      meta = with lib;
      {
        description = "Check archival state of a source code repository and propose to update it if needed.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "tabs"
          "activeTab"
          "scripting"
          "https://archive.softwareheritage.org/*"
          "*://github.com/*"
          "*://bitbucket.org/*"
          "*://gitlab.com/*"
          "*://gitee.com/*"
          "*://pagure.io/*"
          "*://0xacab.org/*"
          "*://gite.lirmm.fr/*"
          "*://framagit.org/*"
          "*://gricad-gitlab.univ-grenoble-alpes.fr/*"
          "*://git.rampin.org/*"
          "*://codeberg.org/*"
          "*://git.disroot.org/*"
          "*://git.minetest.land/*"
          "*://repo.radio/*"
          "*://git.fsfe.org/*"
        ];
        platforms = platforms.all;
      };
    };
    "varia-integrator" = buildMozillaXpiAddon {
      pname = "varia-integrator";
      version = "1.5.6";
      addonId = "giantpinkrobots@protonmail.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4973113/varia_integrator-1.5.6.xpi";
      sha256 = "0a530f7e8acf8cb11125e3e99d89c2813b61ee6130b38be9e504b68e08004bf5";
      meta = with lib;
      {
        homepage = "https://giantpinkrobots.github.io/varia/";
        description = "Route all downloads to Varia if it's running.";
        license = licenses.mpl20;
        mozPermissions = [ "downloads" "storage" "tabs" "cookies" ];
        platforms = platforms.all;
      };
    };
    "worldbrain" = buildMozillaXpiAddon {
      pname = "worldbrain";
      version = "3.20.9";
      addonId = "info@worldbrain.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/4333559/worldbrain-3.20.9.xpi";
      sha256 = "7eef4ff92d314308db2db917e3209950a6abcee3068665e8e24b24d3d4043800";
      meta = with lib;
      {
        homepage = "http://worldbrain.io";
        description = "Remember Everything You Read Online. \nAn open-source and privacy focused extension to Full-Text Search, Annotate and Organise your Web-Research";
        mozPermissions = [
          "<all_urls>"
          "alarms"
          "bookmarks"
          "contextMenus"
          "tabs"
          "webNavigation"
          "notifications"
          "unlimitedStorage"
          "storage"
          "clipboardWrite"
        ];
        platforms = platforms.all;
      };
    };
    "zhongwen" = buildMozillaXpiAddon {
      pname = "zhongwen";
      version = "5.16.0";
      addonId = "{dedb3663-6f13-4c6c-bf0f-5bd111cb2c79}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4482184/zhongwen-5.16.0.xpi";
      sha256 = "98645c53837a419fecfbaf335df80b366e6b6d274bb2a41711c8e3d760756574";
      meta = with lib;
      {
        homepage = "https://github.com/cschiller/zhongwen";
        description = "Official Firefox port of the Zhongwen Chrome extension (http://github.com/cschiller/zhongwen). Translate Chinese characters by hovering over them with the mouse. Includes internal word list, links to Chinese Grammar Wiki, tone colors, and more.";
        license = licenses.gpl2;
        mozPermissions = [ "contextMenus" "tabs" "<all_urls>" ];
        platforms = platforms.all;
      };
    };
  }