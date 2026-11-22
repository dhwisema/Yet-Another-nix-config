{
  config,
  pkgs,
  username,
  ...
}:
{

  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.lixPackageSets.latest.lix;

  nix = {
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 14d";
      };

     #kill with fire
    channel.enable = false;
    settings = {
      use-xdg-base-directories = true;
      http3=true;
      log-format = "multiline-with-logs";
      #remove rce vector allegedly <- space entity
      accept-flake-config = false;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store = true; # Optimise syslinks
      allow-import-from-derivation = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "@wheel"
      ];
    };
  };
}
