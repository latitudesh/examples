rm -rf nix-version.txt
# should ingect via nix for determinsim too
URL="https://install.determinate.systems/nix/tag/v0.36.4/nix-installer-x86_64-linux"
curl -L $URL > nix-installer
chmod +x nix-installer
./nix-installer plan --verbose > nix-installer-plan.json
./nix-installer install --verbose --force nix-installer-plan.json --no-confirm
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix profile install nixpkgs#nixos-anywhere nixpkgs#disko nixpkgs#nixos-install nixpkgs#nixos-install-tools nixpkgs#nixos-facter  --priority 10
nix --version > nix-version.txt
nix flake lock
nix flake check
sudo env PATH=$PATH:/home/ubuntu/.nix-profile/bin/ nixos-facter > facter.json 
sudo env PATH=$PATH:/home/ubuntu/.nix-profile/bin/ nix run 'github:nix-community/disko/latest#disko-install' -- --flake .#default --disk main /dev/sda