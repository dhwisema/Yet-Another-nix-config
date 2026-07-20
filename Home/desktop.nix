{ config, pkgs, ... }:

{
  imports = [
    ./server.nix
    ./common/programs/gaming.nix
    ./common/programs/home-pkgs-desktop.nix
    ./common/Desktop/Niri/niri.nix
  ];
  stylix.enableReleaseChecks = false;
  stylix.targets.firefox.profileNames = [ "profile_0" ];
  xdg.userDirs.enable = true;
  stylix.targets.helix.enable = true;
  programs.ghostty = {
    enableFishIntegration = true;
    settings = {
      shell-integration-features = true;
    };
  };
  programs.fish.enable = true;
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;
  programs.helix.enable = true;
  programs.firefox = {
    enable = true;
    profiles = {
      profile_0 = {
        # choose a profile name; directory is /home/<user>/.mozilla/firefox/profile_0
        id = 0; # 0 is the default profile; see also option "isDefault"
        name = "profile_0"; # name as listed in about:profiles
        isDefault = true; # can be omitted; true if profile ID is 0
        userChrome = ''

          #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
            opacity: 0;
            pointer-events: none;
          }

          #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
              visibility: collapse !important;

          }
        '';
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        # settings = {
        #   # specify profile-specific preferences here; check about:config for options
        #   "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        #   "browser.startup.homepage" = "https://nixos.org";
        #   "browser.newtabpage.pinned" = [
        #     {
        #       title = "NixOS";
        #       url = "https://nixos.org";
        #     }
        #   ];
        #   # add preferences for profile_0 here...
        # };
      };
    };

  };
}
