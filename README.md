# my personal server config.
## To deploy to a new box do the following based on [disko](https://github.com/nix-community/disko) and [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)

 1. Make sure you are able to access root ssh of host system ie in the
    nixos installer or in prior os
    - Create a new folder for the new host. Create Configuration.nix and disk-config.nix. Leaving hardware-configuration.nix alone for
    now. 
     - Also copy disk-config.nix to the generic host
     - add new host to flake.nix
 2. Run on either laptop or desktop: `cd ~/Nix-servers && nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake ./#generic --target-host root@<ip address> `
 3. If no errors found during install yay we installed nix to a new host. 
 4. Post install things to do
	 - Generate ssh key `ssh-keygen -C "<email>"`
    - `cat ~/.ssh/id_ed25519.pub` get result and add ssh key to github account
    - clone repo `git@github.com:dhwisema/Nix-servers.git`
    -  run ` nixos-rebuild switch --flake ~/Nix-servers#<correct device name (probably should be done from the get instead of how step 2
    does it)>`
    - tailscale setup `sudo tailscale up`
    - authenticate tailscale
   
    
|Hostname|Type  |Actual device|Architecture|
|--|--|--|--|
|  Stacy-fakename|Server|Oci ampere altra|aarch64|
|Pumat|Server|Dell optiplex| x64|
|Yasha|Server|MQ90|x64|
|Beau|Desktop|Rtx 4070 super + 7800x3d custom build| x64
|Jester|Desktop|Lenovo thinkpad z16 gen 1|x64

## Secure boot?
I fear im not sure how to deal with more than one disk but this note currently only applies to jester.
The order is most likely wrong but tpm based disk unlock works with ```sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="0+2+7+15:sha256=0000000000000000000000000000000000000000000000000000000000000000" /dev/nvme0n1p2``` based on [ElvishJerricco reccomendation about tpm 2 disk unlock](https://discourse.nixos.org/t/a-modern-and-secure-desktop-setup/41154/17).
Also requires [Lanzaboote](https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html)
