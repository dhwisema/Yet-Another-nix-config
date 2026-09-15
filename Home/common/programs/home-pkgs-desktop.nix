{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [ ./glide.nix ];
  home.packages = with pkgs; [
    onlyoffice-desktopeditors
    smplayer
    foliate
    ghostty
    nixfmt
    nixfmt-tree
    kicad
    nil
    signal-desktop
    element-desktop
    obsidian
    nixd
    zoxide
    devenv
    webcord-vencord
    ungoogled-chromium
  ];

  programs.zellij = {
    enable = true;
    settings = {
      copy_command = "wl-copy";
    };
  };
  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
    };
    settings = {
      close_on_focus_loss = true;
      favicon_service = "twenty";
      launcher_window = {
        opacity = lib.mkForce 1;
      };

      theme = {
        light = {
          name = "stylix";
        };
        dark = {
          name = "stylix";
        };
      };
    };

    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      # bluetooth
      nix
      niri
      firefox
      wifi-commander
      # Extension names can be found in the link below, it's just the folder namesi
      # https://github.com/vicinaehq/extensions/tree/main/extensions

    ];
  };
}
