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
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    # device = "/dev/sda";
    efiSupport = true;
    # efiInstallAsRemovable = true;
    enable = true;
    default = "0";
    splashImage = null;
  };
  # boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 1;
  # boot.swraid.enable = false;
  # systemd.network.enable = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
  };
  networking.firewall = {
    allowedTCPPorts = [
      22
      80
      443
      8080
      8443
    ];
  };

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

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "prohibit-password";
  };

  # networking.useDHCP = lib.mkForce false;
  # networking.useDHCP = true;
  # networking.dhcpcd.enable = true;

  # services.cloud-init = {
  #   enable = true;
  #   network.enable = true;
  #   settings = {
  #     datasource_list = [ "ConfigDrive" ];
  #     datasource.ConfigDrive = { };
  #   };
  # };

  #latsh has not the fastest and robust ssh connection, so we need mosh
  programs.mosh.enable = true;
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org/"
      "https://cache.nixos.org/"
      "https://nixpkgs-update.cachix.org"
    ];

    trusted-public-keys = [
      "nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6/+Iy8eZX2ajf09e4EE9SnxSML1W8="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "nixos"
      "ubuntu"
    ];
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  # services.sshd.enable = true;
  # networking.networkmanager.enable = true;
  # autologin
  services = {
    getty.autologinUser = "ubuntu";
  };

  users.users.ubuntu = {
    isNormalUser = true;
    home = "/home/ubuntu";
    extraGroups = [
      "wheel"
      # "networkmanager"
    ];
    initialHashedPassword = "";
    # yeah, need to make it flake input (so can override it as needed)
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/PGg+j/Y5gP/e7zyMCyK+f0YfImZgKZ3IUUWmkoGtT dzmitry@nullstudios.xyz"
    ];
  };
  # no passwords
  users.users.root.initialHashedPassword = "";
  security.polkit.enable = true;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraRules = [
      {
        users = [
          "ubuntu"
          "nixos"
        ];
        commands = [
          {
            command = "ALL";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
        ];
      }
    ];
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.nano
    pkgs.util-linux
  ];

  system.stateVersion = "24.05";
}
