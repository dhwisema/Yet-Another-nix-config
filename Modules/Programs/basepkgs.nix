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
  ];
  programs.yazi = {
    enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
