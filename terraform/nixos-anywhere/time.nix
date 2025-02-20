# setups time
{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  services = {
    # legacy
    ntpd.enable = false;
    # not exactly for servers
    timesyncd.enable = false;

    /*
     supports Network Time Security and Precision Time Protocol like thing
      */
    chrony = {
      enable = true;
      enableNTS = true;
      servers = [
        "time.google.com"
        "time.aws.com"
        "time.cloudflare.com"
        "time.nist.gov"
        "ntp.nict.jp"
        "ntp.nat.ms"
      ];
    };

  };

}
