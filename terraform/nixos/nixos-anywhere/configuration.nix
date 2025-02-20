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



# enp1s0f0
# 


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


#     config =
#     {
#       # assertions = [
#       #   {
#       #     assertion = config.systemd.network.networks."10-uplink".networkConfig ? Address;
#       #     message = ''
#       #       The machine IPv6 address must be set to
#       #       `systemd.network.networks."10-uplink".networkConfig.Address`
#       #     '';
#       #   }
#       # ];

#       boot.initrd.availableKernelModules = [
#         "xhci_pci"
#         "ahci"
#         # SATA SSDs/HDDs
#         "sd_mod"
#         # NVME
#         "nvme"
#       ];



#       # systemd.network.networks."10-uplink" = {
#       #   matchConfig.Name = lib.mkDefault "en* enp1s0f0";
#       #   networkConfig.DHCP = "ipv4";
#       #   # hetzner requires static ipv6 addresses
#       #   networkConfig.Gateway = "fe80::1";
#       #   networkConfig.IPv6AcceptRA = "no";
#       # };

#       # This option defaults to `networking.useDHCP` which we don't enable
#       # however we do use DHCPv4 as part of `10-uplink`, so we want to
#       # enable this for legacy stage1 users.
#       boot.initrd.network.udhcpc.enable = lib.mkIf (!config.boot.initrd.systemd.enable) true;

#       # Network configuration i.e. when we unlock machines with openssh in the initrd
#       boot.initrd.systemd.network.networks."10-uplink" = config.systemd.network.networks."10-uplink";
#       boot.kernelModules = [ "kvm-intel" ];
#       hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
#     }
#     // (lib.optionalAttrs ((options.srvos.boot or { }) ? consoles) {

#       # To make hetzner kvm console work. It uses VGA rather than serial. Serial leads to nowhere.
#       srvos.boot.consoles = lib.mkDefault [ ];
#     });
# }