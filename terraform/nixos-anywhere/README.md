

 nix run github:nix-community/nixos-anywhere -- --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix -i ~/.ssh/id_ed25519 --target-host ubuntu@103.88.232.199


nix run github:nix-community/nixos-anywhere -- --flake .#default --generate-hardware-config nixos-facter facter.json ubuntu@103.88.232.159 