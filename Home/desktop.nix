{ config, pkgs, ... }:

{
  imports = [
    ./server.nix
    ./common/programs/gaming.nix
    ./common/programs/home-pkgs-desktop.nix
    ./common/Desktop/Niri/niri-home.nix
    ./common/Desktop/themeing/gtk.nix
  ];
  xdg.userDirs.enable = true;
  programs.fish.enable = true;
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;
  programs.helix.enable = true;
}
