# would be awesome to use systemd-boot and EFI - simpler/faster,
# but LatSh does not have that
{
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];
  # allows to boot from raids
  boot.swraid.enable = false;

  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              # for grub MBR
              type = "EF02";
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
