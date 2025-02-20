# boot via grup, not EFI, becuase LatSh does not supports EFI
{
  ...
}:
{
  boot.loader.grub.default = "0";
  boot.loader.timeout = 0;
  boot.loader.grub.splashImage = null;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.grub.enable = true;
  # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  # use `mirroredBoots` for RAID-1
  # next to be empty for non RAID-1, disko sets proper value
  # boot.loader.grub.device(s)
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  services.cloud-init = {
    # allow cloud-init hacks, so not ideal
    enable = true;
    # systemd-networkd integration
    network.enable = true;
  };
}
