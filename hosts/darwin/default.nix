{
  username,
  homeStateVersion,
  homeDirectory,
  ...
}:
{
  imports = [
    ../../modules/darwin
  ];

  system.primaryUser = username;

  users.users.${username}.home = homeDirectory;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "before-home-manager";
  home-manager.users.${username} = {
    imports = [
      ../../modules/common
      (
        { lib, pkgs, ... }:
        {
          xdg.configFile."ghostty".source = ../../config/ghostty;

          home.packages = [ pkgs.duti ];

          # Keep PDFs out of Preview and open them with the current default
          # browser. Querying the HTML handler makes this follow browser
          # changes instead of hard-coding Vivaldi's bundle identifier.
          home.activation.openPdfsInDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            browser_bundle_id="$(${pkgs.duti}/bin/duti -x html | tail -n 1)"

            if [ -z "$browser_bundle_id" ]; then
              echo >&2 "error: could not determine the default browser"
              exit 1
            fi

            $DRY_RUN_CMD ${pkgs.duti}/bin/duti -s "$browser_bundle_id" com.adobe.pdf all
          '';

          # Karabiner rewrites karabiner.json when its settings change, so a
          # read-only Home Manager symlink is not suitable here. Keep device
          # enable/disable choices local to each Mac while refreshing the
          # shared mappings from this repository on every activation.
          home.activation.installKarabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            config_dir="$HOME/.config/karabiner"
            config_file="$config_dir/karabiner.json"
            managed_config=${../../config/karabiner/karabiner.json}
            merged_config="$config_dir/.karabiner.json.home-manager"

            $DRY_RUN_CMD mkdir -p "$config_dir"
            if [ -L "$config_file" ]; then
              $DRY_RUN_CMD rm "$config_file"
            fi

            if [ -f "$config_file" ] && ${pkgs.jq}/bin/jq -e 'type == "object"' "$config_file" > /dev/null; then
              ${pkgs.jq}/bin/jq -s '
                .[0] as $managed
                | .[1] as $local
                | $managed
                | .profiles |= map(
                    . as $profile
                    | ($local.profiles // [] | map(select(.name == $profile.name)) | first) as $local_profile
                    | if $local_profile != null and ($local_profile | has("devices"))
                      then .devices = $local_profile.devices
                      else .
                      end
                  )
              ' "$managed_config" "$config_file" > "$merged_config"
              $DRY_RUN_CMD install -m 600 "$merged_config" "$config_file"
              $DRY_RUN_CMD rm "$merged_config"
            else
              $DRY_RUN_CMD install -m 600 "$managed_config" "$config_file"
            fi
          '';
        }
      )
    ];

    home.username = username;
    home.homeDirectory = homeDirectory;
    home.stateVersion = homeStateVersion;
  };
}
