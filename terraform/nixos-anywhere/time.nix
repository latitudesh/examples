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
      supports Network Time Security and Precision Time Protocol like thing(network RTT correction).
      also can consider ntpd-rs
    */
    chrony = {
      enable = true;
      enableNTS = true;
      # List of globally distributed NTS on time servers, better be correct then fast
      servers = [
        "time.cloudflare.com nts iburst" # US Cloudflare
        "nts.netnod.se nts iburst" # Stockholm
        "	ntp.3eck.net nts iburst" # Switzerland
        "ntpmon.dcs1.biz nts iburst" # Singapore
        "ntp1.glypnod.com nts iburst" # San Francisco
        "ntp2.glypnod.com nts iburst" # London
      ];
    };

  };

}
