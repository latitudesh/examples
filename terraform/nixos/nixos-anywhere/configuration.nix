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



# enp1s0f0
# services.openssh.settings.ClientAliveInterval = 180;


# null_resource.nixos (local-exec): + uname -r
# null_resource.nixos (local-exec): + printf %s\n 6.1 6.8.0-53-generic
# null_resource.nixos (local-exec): + kexecSyscallFlags=--kexec-syscall-auto
# null_resource.nixos (local-exec): + sh -c '/root/kexec/kexec/kexec' --load '/root/kexec/kexec/bzImage'   --kexec-syscall-auto      --initrd='/root/kexec/kexec/initrd' --no-checks   --command-line 'init=/nix/store/4g9j050k7pnbb2n43dssv6sndfarl81n-nixos-system-nixos-installer-24.11pre-git/init nouveau.modeset=0 console=tty0 console=ttyS0,115200 root=fstab loglevel=4'
# null_resource.nixos (local-exec): machine will boot into nixos in 6s...
# null_resource.nixos (local-exec): + echo machine will boot into nixos in 6


  # network:
  #   network:
  #     version: 2
  #     ethernets:
  #       enp1s0f0:
  #         dhcp4: no
  #         addresses: [$PUBLIC_IP]
  #         gateway4: $PUBLIC_GATEWAY
  #         nameservers:
  #           addresses: [8.8.8.8, 8.8.4.4]


    # networking.defaultGateway = {
  #   address = "103.14.27.184";
  #   interface = "enp1s0f0";
  # };
  # networking.interfaces = {
  #   enp1s0f0 = {
  #     enable = true;
  #     dhcp4 = false;
  #     # ipv4 = {
  #     #   addresses = [
  #     #     {
  #     #       address = "103.14.27.107";
  #     #       prefixLength = 31;
  #     #     }
  #     #   ];
  #     # };
  #   };
  # };