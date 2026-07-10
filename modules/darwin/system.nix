{ pkgs, username, ... }:
let
  homeDirectory = "/Users/${username}";
in
{
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  # nix-darwin owns /etc/shells when environment.shells is set. On the first
  # activation, move the existing file aside:
  #
  #   sudo mv /etc/shells /etc/shells.before-nix-darwin
  environment.shells = with pkgs; [
    bashInteractive
    zsh
    nushell
  ];

  programs.zsh.enable = true;

  users.users.${username}.shell = pkgs.nushell;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    # Mouse settings shared by global preferences.
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 0.5;
    };

    # Locale and preferred languages.
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      NSGlobalDomain = {
        AppleLanguages = [
          "en-JP"
          "ja-JP"
        ];
        AppleLocale = "en_JP";
      };
    };

    # User-wide macOS defaults such as appearance, keyboard repeat, and input.
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 0;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleSpacesSwitchOnActivate = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSTableViewDefaultSizeMode = 1;
      "com.apple.keyboard.fnState" = false;
      "com.apple.springing.delay" = 0.5;
      "com.apple.springing.enabled" = true;
      "com.apple.swipescrolldirection" = false;
      "com.apple.trackpad.forceClick" = true;
      "com.apple.trackpad.scaling" = 0.6875;
    };

    # Control Center and menu bar items.
    controlcenter = {
      BatteryShowPercentage = true;
    };

    # Dock layout, pinned apps, stacks, gestures, and hot corners.
    dock = {
      autohide = true;
      largesize = 16;
      magnification = false;
      mru-spaces = false;
      persistent-apps = [
        "/Applications/Vivaldi.app"
        "/Applications/Craft.app"
        "/Applications/Ghostty.app"
      ];
      persistent-others = [
        {
          folder = {
            path = "${homeDirectory}/Downloads";
            arrangement = "date-added";
            displayas = "stack";
            showas = "fan";
          };
        }
      ];
      show-recents = false;
      showAppExposeGestureEnabled = true;
      showDesktopGestureEnabled = false;
      showLaunchpadGestureEnabled = false;
      showMissionControlGestureEnabled = true;
      tilesize = 58;
      wvous-br-corner = 14;
    };

    # Finder visibility, default view, search scope, and desktop devices.
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXDefaultSearchScope = "SCev";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      NewWindowTarget = "Home";
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowPathbar = true;
      ShowRemovableMediaOnDesktop = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };

    # Screenshot behavior.
    screencapture = {
      target = "clipboard";
    };

    # Clock display in the menu bar.
    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 0;
      ShowDayOfWeek = true;
    };
  };

  # Hardware keyboard remapping.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  system.stateVersion = 6;
}
