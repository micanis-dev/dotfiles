{ config, lib, pkgs, username, ... }:
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

  # environment.shells only adds Nushell to /etc/shells; it does not create
  # /run/current-system/sw/bin/nu, which is the stable login-shell path below.
  environment.systemPackages = [ pkgs.nushell ];

  programs.zsh.enable = true;

  # nix-darwin deliberately leaves properties of existing macOS users alone
  # unless it owns the whole account via users.knownUsers. The primary admin
  # user must remain macOS-managed, so enforce only its login shell here.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    desired_shell=/run/current-system/sw/bin/nu
    current_shell="$(dscl . -read /Users/${username} UserShell 2> /dev/null | awk '{ print $2 }')"

    if [ "$current_shell" != "$desired_shell" ]; then
      echo >&2 "setting ${username}'s login shell to Nushell..."
      dscl . -create /Users/${username} UserShell "$desired_shell"
    fi

    configured_shell="$(dscl . -read /Users/${username} UserShell | awk '{ print $2 }')"
    if [ "$configured_shell" != "$desired_shell" ]; then
      echo >&2 "error: failed to set ${username}'s login shell to Nushell"
      exit 1
    fi
  '';

  security.pam.services.sudo_local.touchIdAuth = true;

  # Install the CLI and run tailscaled as a system daemon from boot. This
  # avoids depending on the GUI app or a per-user login item.
  services.tailscale.enable = true;

  # This is a one-time migration from the formerly managed GUI cask. The
  # conditional keeps subsequent activations idempotent.
  system.activationScripts.removeTailscaleApp.text = ''
    if ${config.homebrew.prefix}/bin/brew list --cask tailscale-app > /dev/null 2>&1; then
      ${config.homebrew.prefix}/bin/brew uninstall --cask tailscale-app
    fi
  '';

  # Keep the system awake so background services such as Tailscale remain
  # connected, while allowing idle displays to sleep after one hour.
  power.sleep.computer = "never";
  power.sleep.display = 60;

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

      # Disable Japanese IME Live Conversion so candidates are only committed
      # explicitly.
      "com.apple.inputmethod.Kotoeri" = {
        JIMPrefLiveConversionKey = false;
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

  system.stateVersion = 6;
}
