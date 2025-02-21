nix flake lock
nix flake check
chmod +x disko-install.sh
sudo env PATH="$PATH:/home/ubuntu/.nix-profile/bin/" nixos-facter > facter.json
# sudo env PATH="$PATH:/home/ubuntu/.nix-profile/bin/:" ./disko-install.sh --flake .#default --disk main /dev/sda --mode format