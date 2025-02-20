# boot via grup, not EFI, becuase LatSh does not supports EFI
{
  ...
}:
{

  # default = "0";
  boot.loader.timeout = 0;
  boot.loader.grub.splashImage = null;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.grub.enable = true;
  # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  # use `mirroredBoots` for RAID-1
  boot.loader.grub.devices = [ "/dev/sda" ];
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  services.cloud-init = {
    # allow cloud-init hacks, so not ideal
    enable = true;
    # systemd-networkd integration
    network.enable = true;
    settings = {
      datasource_list = [ "ConfigDrive" ];
      datasource.ConfigDrive = { };
    };
  };
}
