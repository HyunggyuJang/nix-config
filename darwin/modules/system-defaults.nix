{ config, owner, ... }:
let
  homePath = config.users.users.${owner}.home;
in
{
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = true;
    allowSignedApp = true;
    blockAllIncoming = false;
  };

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
      # Bottom-right hot corner action
      wvous-br-corner = 14;
    };

    # Keep Apple window management out of the way while using yabai/skhd.
    WindowManager = {
      GloballyEnabled = false;
      AppWindowGroupingBehavior = true;
      AutoHide = false;
      HideDesktop = true;
      StandardHideWidgets = false;
      StageManagerHideWidgets = false;
      EnableStandardClickToShowDesktop = false;
      StandardHideDesktopIcons = true;
      EnableTilingByEdgeDrag = false;
      EnableTopTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      EnableTiledWindowMargins = false;
    };

    spaces.spans-displays = false;

    trackpad = {
      ActuateDetents = true;
      Clicking = false;
      DragLock = false;
      Dragging = false;
      FirstClickThreshold = 1;
      ForceSuppressed = false;
      SecondClickThreshold = 1;
      TrackpadCornerSecondaryClick = 0;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadMomentumScroll = true;
      TrackpadPinch = true;
      TrackpadRightClick = true;
      TrackpadRotate = true;
      TrackpadThreeFingerDrag = false;
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 2;
      TrackpadTwoFingerDoubleTapGesture = true;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = false;
      FXPreferredViewStyle = "Nlsv"; # list view
      ShowPathbar = true;
      ShowStatusBar = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      # Finder's default location upon open
      NewWindowTarget = "Other";
      NewWindowTargetPath = "file://${homePath}/";
    };

    loginwindow.GuestEnabled = false;

    screencapture = {
      target = "clipboard";
      show-thumbnail = false;
      include-date = false;
      type = "png";
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    menuExtraClock = {
      ShowAMPM = true;
      ShowDayOfWeek = true;
      ShowDate = 0;
    };

    controlcenter = {
      AirDrop = false;
      BatteryShowPercentage = true;
      Bluetooth = false;
      Display = false;
      FocusModes = false;
      NowPlaying = false;
      Sound = false;
    };

    LaunchServices.LSQuarantine = true;

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleKeyboardUIMode = 3;
      AppleShowScrollBars = "WhenScrolling";
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleWindowTabbingMode = "manual";
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
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
      "com.apple.springing.enabled" = true;
      "com.apple.springing.delay" = 0.5;
    };

    CustomUserPreferences = {
      # Not natively covered by nix-darwin's finder module yet.
      "com.apple.finder".ShowSidebar = true;

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
      "com.apple.loginwindow".TALLogoutSavesState = false;
      # Not currently exposed via system.defaults.NSGlobalDomain options.
      NSGlobalDomain = {
        AppleLanguages = [ "en-KR" "ko-KR" ];
        AppleLocale = "en_KR";
        AppleMiniaturizeOnDoubleClick = false;
        "com.apple.sound.beep.flash" = false;
      };
    };
  };
}
