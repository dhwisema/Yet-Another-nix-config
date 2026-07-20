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
    distrobox-tui
    distrobox # dont need this currently will reneable if i have to use code composer again.i
    smplayer
    foliate
    #vesktop
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

    # ltspice
    # picocom
    # wireshark
    # binwalk
    # bintools
    # busybox
    # mqtt-explorer
    # mqttmultimeter
    # mqttmultimeter
    # esptool
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
