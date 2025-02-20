{
  description = "Instantiate Ubuntu and deploy Nixos WebServer on it";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs =
    inputs@{
      flake-parts,
      disko,
      nixpkgs,
      nixos-facter-modules,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              opentofu # terraform 
              # used to generate hardware configuration. generate once, and reuse for all specific machine type
              facter
            ];
          };
        };
      flake = {
        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            nixos-facter-modules.nixosModules.facter
            ./configuration.nix
          ];
        };
      };
    };
}
