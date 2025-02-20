nix flake lock
nix flake check
sudo env PATH="$PATH:/home/ubuntu/.nix-profile/bin/" nixos-facter > facter.json 
sudo env PATH="$PATH:/home/ubuntu/.nix-profile/bin/:" ./disko-install --flake .#default --disk main /dev/sda