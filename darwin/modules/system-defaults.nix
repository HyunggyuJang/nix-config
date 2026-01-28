{ config, owner, ... }:
{
  system.defaults = {
    dock = {
      orientation = "left";
      autohide = true;
      launchanim = false;
      show-process-indicators = true;
      show-recents = false;
      static-only = true;
      mru-spaces = false;
      minimize-to-application = true;
    };

    spaces.spans-displays = false;

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = false;
      FXPreferredViewStyle = "Nlsv"; # list view
      ShowPathbar = true;
    };

    loginwindow.GuestEnabled = false;

    CustomUserPreferences = {
      # Finder's default location upon open
      "com.apple.finder" = {
        NewWindowTargetPath =
          let homePath = config.users.users.${owner}.home;
          in "file://${homePath}/";
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
        # Do not download newly available updates in background
        AutomaticDownload = 0;
        # Install System data files & security updates
        CriticalUpdateInstall = 1;
      };
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    };

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleKeyboardUIMode = 3;
      AppleShowScrollBars = "WhenScrolling";
      AppleInterfaceStyleSwitchesAutomatically = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSScrollAnimationEnabled = false;
      NSUseAnimatedFocusRing = false;
      NSTextShowsControlCharacters = true;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSTableViewDefaultSizeMode = 1;
      _HIHideMenuBar = true;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.trackpad.forceClick" = true;
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.trackpadCornerClickBehavior" = null;
      "com.apple.keyboard.fnState" = true;
    };
  };
}
