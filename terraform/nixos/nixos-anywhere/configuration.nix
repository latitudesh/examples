# just central hub to assemble config from several
{
  modulesPath,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/headless.nix")
    ./nix.nix
    ./hardware.nix
    ./storage.nix
    ./networking.nix
    ./access.nix
  ];

  system.stateVersion = "24.05";
}