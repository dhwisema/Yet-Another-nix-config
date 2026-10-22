{ config, pkgs, ... }:

{
  imports = [
    ./server.nix
    ./common/programs/gaming.nix
    ./common/programs/home-pkgs-desktop.nix
    ./common/Desktop/Niri/niri-home.nix
  ];
  stylix.enableReleaseChecks = false;
  stylix.targets.firefox.profileNames = [ "profile_0" ];
  xdg.userDirs.enable = true;
  stylix.targets.helix.enable = true;
  stylix.targets.ghostty.enable = false;
  programs.ghostty = {
    enableFishIntegration = true;
    settings = {
      shell-integration-features = true;
      theme = "Everforst Dark Hard";
    };
  };
  programs.fish.enable = true;
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;
  programs.helix.enable = true;
}
