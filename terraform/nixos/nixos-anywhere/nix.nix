# ensure we have flakes and caches
{ config, ... }:
{

  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org/"
      "https://cache.nixos.org/"
      "https://nixpkgs-update.cachix.org"
    ];

    trusted-public-keys = [
      "nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6/+Iy8eZX2ajf09e4EE9SnxSML1W8="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "nixos"
      "ubuntu"
    ];
  };
}
