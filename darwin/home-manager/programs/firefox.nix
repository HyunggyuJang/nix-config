{
  lib,
  pkgs,
  hostName,
  inputs,
  ...
}:
{
  programs.firefox.enable = true;
  programs.firefox.package = lib.makeOverridable ({ ... }: pkgs.firefox-bin) { };
  programs.firefox.profiles = {
    home = {
      id = 0;
      settings = {
        "app.update.auto" = false;
        "browser.startup.homepage" = "https://start.duckduckgo.com";
        "browser.search.region" = "KR";
        "browser.search.countryCode" = "KR";
        "browser.search.isUS" = true;
        "browser.ctrlTab.recentlyUsedOrder" = false;
        "browser.newtabpage.enabled" = false;
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.uidensity" = 1;
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "browser.urlbar.update1" = true;
        "distribution.searchplugins.defaultLocale" = "en-KR";
        "general.useragent.locale" = "en-KR";
        "identity.fxaccounts.account.device.name" = hostName;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.annotate.enabled" = true;
        "reader.color_scheme" = "sepia";
        "services.sync.declinedEngines" = "addons,passwords,prefs";
        "services.sync.engine.addons" = false;
        "services.sync.engineStatusChanged.addons" = true;
        "services.sync.engine.passwords" = false;
        "services.sync.engine.prefs" = false;
        "services.sync.engineStatusChanged.prefs" = true;
        "signon.rememberSignons" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = builtins.readFile ../files/firefox/userChrome.css;
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.system}; [
        ublock-origin
        browserpass
        tridactyl
        darkreader
        # For work with kazuki
        # metamask
        # Need to add zotero-connector
        # -> there is no official extension registered in the mozilla's store.
        # Let's use edge's for now.

        # Recommended by Lechuck
        # multi-account-containers
      ];
    };
  };
}
