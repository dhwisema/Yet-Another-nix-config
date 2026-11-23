{ pkgs, config, ... }: {
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      show_startup_tips = false;
      theme = "everforest-dark";
      copy_commad = "wl-copy";
    };
  };
}
