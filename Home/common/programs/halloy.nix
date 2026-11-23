{ pkgs, config, ... }: {
  programs.halloy = {
    enable = true;
    settings = {
      theme = "base16-everforest-dark-hard";

    };
  };
}
