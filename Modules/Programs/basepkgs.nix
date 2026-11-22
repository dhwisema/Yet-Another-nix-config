{
  config,
  lib,
  pkgs,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    curl
    wget
    btop
    jq
    fzf
    ripgrep
    helix
    yazi
    eza
   ];
  programs.yazi = {
    enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
