# just central hub to assemble config from several
{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/headless.nix")
    ./disk-config.nix
  ];

  system.stateVersion = "24.05";
}
