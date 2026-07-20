{
  config,
  pkgs,
  username,
  ...
}:

{

  programs.git = {
    enable = true;
    settings = {
      user.email = "dhwisema@ncsu.edu";
      user.name = "dhwisema";
    };
  };

  imports = [ ./common/programs/home-pkgs-server.nix ];

  home = {
    packages = with pkgs; [
    ];
    enableNixpkgsReleaseCheck = false; # because unstable and hm just doesnt care so 25.11 and 26.05 and so on
    # username = "irrelevancy"; # may break
    username = username;
    stateVersion = "26.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
