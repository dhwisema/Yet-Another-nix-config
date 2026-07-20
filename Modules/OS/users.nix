{
  config,
  lib,
  pkgs,
  username,
  role,
  ...
}:
{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Open ports in the firewall.
  #lowkey i think i can close this now because tailscale...
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Enable passwordless sudo.
  # wait this is lowkey extra bad wtf.
  # security.sudo.extraRules = [
  #   {
  #     users = [ username ];
  #     commands = [
  #       {
  #         command = "ALL";
  #         options = if role == "server" then [ "NOPASSWD" ] else [];
  #       }
  #     ];
  #   }
  # ];
  users = {
    mutableUsers = if role == "server" then false else true;
    users.${"irrelevancy"} = {
      hashedPassword = "$y$j9T$tsD8VLtqLhL5a/OIA7Txb1$bpOz8kmMODZVSPITsRMjhKd59m2Wvvhhh7w/ElmFdn1";
      isNormalUser = true;
      extraGroups =
        if role == "server" then
          [
            "networkmanager"
            "wheel"
          ]
        else
          [
            "networkmanager"
            "wheel"
            "plugdev"
            "dialout"
          ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWcxSaxxRfizmQh2zdrRCt0Ic+eVKOc2w+nsQOVBh+e irrelevancy@Jester" # jester
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINVkFiDUTkFwLQ3g13XgdN5ekhmNYo5whYn+JmjTvLYu huntingdog5forsteam@gmail.com" # beau
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRfTaWtXV2hXANtyDFTw+4rCjJxHyRi8JCTNxloOvYM root@localhost"
      ];
    };
  };
}

# "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNqgtA5a1QhGLKCnDciSLlbgUmNl5KYof46nrNirLK0 root@localhost"
