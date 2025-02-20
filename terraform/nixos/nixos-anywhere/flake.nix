{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

  outputs =
    {
      disko,
      nixpkgs,
      nixos-facter-modules,
      ...
    }:
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
           disko.nixosModules.disko
           nixos-facter-modules.nixosModules.facter
          ./configuration.nix
        ];
      };
    };
}




