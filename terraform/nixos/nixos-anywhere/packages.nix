# packages which will be used by user
{ pkgs, lib, ... }:
{
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.nano
    pkgs.util-linux
    pkgs.disko
  ];

  # latsh has not the fastest and robust ssh connection, so we need mosh
  programs.mosh.enable = true;
}
