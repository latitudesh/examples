# based on https://github.com/nix-community/nixos-anywhere-examples/blob/main/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  inputs.srvos.url = "github:nix-community/srvos";
  # Use the version of nixpkgs that has been tested to work with SrvOS
  # Alternatively we also support the latest nixos release and unstable
  inputs.nixpkgs.follows = "srvos/nixpkgs";
  outputs =
    {
      nixpkgs,
      disko,
      nixos-facter-modules,
      srvos,
      ...
    }:
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          nixos-facter-modules.nixosModules.facter
          {
            config.facter.reportPath = ./facter.json;
          }
          ./srvos.nix
          # srvos.nixosModules.hardware-hetzner-online-intel
        ];
      };
    };
}
