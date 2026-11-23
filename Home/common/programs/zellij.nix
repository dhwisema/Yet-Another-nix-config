{ pkgs, config, ... }: {
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "everforest-dark";
    };
  };
}
