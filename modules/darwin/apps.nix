# GUI apps installed through Homebrew casks and the Mac App Store.
{
  homebrew = {
    casks = [
      "bitwarden"
      "craft"
      "discord"
      "docker-desktop"
      "ghostty"
      "jump-desktop-connect" # host agent; the client is in masApps
      "karabiner-elements"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "notion"
      "raycast"
      "slack"
      "vivaldi"
      "zoom"
    ];

    masApps = {
      # Purchased on the App Store; the Homebrew cask is the web-store
      # build, which needs a separate license.
      "Jump Desktop" = 524141863;
      "RunCat Neo" = 6757801838;
    };
  };
}
