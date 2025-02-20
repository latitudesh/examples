rm -rf nix-version.txt
# should ingect via nix for determinsim too
URL="https://install.determinate.systems/nix/tag/v0.36.4/nix-installer-x86_64-linux"
curl -L $URL > nix-installer
chmod +x nix-installer
./nix-installer plan --verbose > nix-installer-plan.json
./nix-installer install --verbose --force nix-installer-plan.json --no-confirm
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix profile install nixpkgs#util-linux  nix profile install nixpkgs#disko | nix profile install nixpkgs#nixos-install | nix profile install nixpkgs#nixos-install-tools | nix profile install nixpkgs#nixos-facter | true
nix --version > nix-version.txt