{
  config,
  lib,
  pkgs,
}:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    systemd.enable = true;
    settings = {
      theme = "everforest dark hard";
      shell-integration-features = true;
      window-decoration = "client";
      font-family = "FiraCode Nerd Font";
    };
  };
}
