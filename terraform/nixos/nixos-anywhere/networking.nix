/* setups networking */
{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    /* empty allows to get it from DHCP.
      not clear if it would be good to set it to subdomain for example, but option
      integration is intresting to do
     */
    hostName = "";

    # automatic for servers, little bit bloated then manual, but generic and just works
    useNetworkd = true;

    # used by useNetworkd for dynamic network discovery
    dhcpcd = {
      enable = true;
    };

    # this is for desktops an wifi, ensure disable it
    networkmanager.enable = false;
    # not needed when using networkd
    useDHCP = false;

    firewall = {
      /* opens well known ports, please consider to modify as needed */
      allowedTCPPorts = [
        22 # ssh
        80 # http
        443 # https
        8080 # alt-http
        8443 # alt-https
      ];
      /* for http3 */
      allowedUDPPorts = [
        80 # http
        443 # https
        8080 # alt-http
        8443 # alt-https     
        123 # ntp
        53 # dns   
      ];

      # we leave `interfaces` and `defaultGateway` to automatic configuration
    };

      nameservers = [
        "8.8.8.8" # US Google
        "1.1.1.1" # US Cloudflare
        "95.85.95.85" # EU
      ];     
  };

  /* enables networkd */
  systemd.network.enable = true;
}



