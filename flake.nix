{
  description = "combined nixos config for servers and dekstops";
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    disko = {
      # declarative disk management
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
    waveforms.url = "github:liff/waveforms-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glide-browser = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs =
    inputs:
    with inputs; # weird syntax thing.... i think its neat apparantly this would work but,,, 2026 01 06 -> i fear i understand that this way causes me pain
    let
      username = "irrelevancy";
      mkNixosConfiguration =
        {
          system ? "x86_64-linux",
          role ? "server",
          disko-use ? false,
          hostname,
          modules,
        }@args-os:
        let
          defaultconf =
            if role == "server" then
              [
                ./Modules/OS/Base-config.nix
                ./Modules/OS/comin.nix
              ]
            else
              [
                ./Modules/OS/desktop-config.nix
                stylix.nixosModules.stylix
                nixos-hardware.nixosModules.common-cpu-amd # sets scheduling things for kernel
                nixos-hardware.nixosModules.common-pc-ssd # ssd trim
              ];
          diskopath = ./. + "/Host/${hostname}/disk-config.nix";
          hwconf = ./. + "/Host/${hostname}/hardware-configuration.nix";
          config-nix = ./. + "/Host/${hostname}";
          diskoconf = lib.optionals disko-use [
            disko.nixosModules.disko
            diskopath
          ];
          default-hm = if role == "server" then [ ./Home/server.nix ] else [ ./Home/desktop.nix ];
          specialArgs = {
            inherit
              inputs
              username
              hostname
              role
              ;
          }
          // args-os;
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            # (specialArgs)
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit inputs username; };
              home-manager.users.${username} = {
                imports = default-hm;
              };
            }
            hwconf
            config-nix
            sops-nix.nixosModules.sops
          ]
          ++ modules
          ++ defaultconf
          ++ diskoconf;
        };
    in
    {
      nixosConfigurations = {
        Jester = mkNixosConfiguration {
          hostname = "Jester";
          role = "Desktop";
          modules = [ ];
        }; # thinkpad z16
        Beau = mkNixosConfiguration {
          hostname = "Beau";
          role = "Desktop";
          modules = [ ];
        }; # 7800x3d gaming pc
        Stacy-Fakename = mkNixosConfiguration {
          disko-use = true;
          hostname = "Stacy-Fakename";
          system = "aarch64-linux";
          modules = [ ];
        }; # oracle cloud box
        Pumat = mkNixosConfiguration {
          disko-use = true;
          hostname = "Pumat";
          modules = [ ];
        }; # dell optiplex
        Yasha = mkNixosConfiguration {
          hostname = "Yasha";
          modules = [ ];
        }; # lenovo mq90
      };
    };
}
