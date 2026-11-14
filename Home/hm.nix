{inputs,config,pkgs,role,username,...}:
let
   default-hm = if role == "server" then [ ./Home/server.nix ] else [ ./Home/desktop.nix ];
in{
             imports = [inputs.home-manager.nixosModules.home-manager]; # todo move this into a seperate file for the love of god
            
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit inputs username; };
              home-manager.users.${username} = {
                imports = default-hm;
              };
            

}
