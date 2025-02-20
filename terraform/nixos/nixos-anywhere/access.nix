# local and ssh users
# disables all passwords, only keys can be used
# makes ubuntu user autologin and root
# setups time
{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  /* autologin into TTY1 */
 services.getty.autologinUser = "ubuntu"; 
 /* ensure enabled */
 systemd.services."getty@tty1".enable = false;



  services.openssh = {
    /* same as services.sshd.enable = false; */
    enable = true;
    /* setting port explicitly */
    ports = [ 22 ];
    settings.PasswordAuthentication = false;    
    settings.PermitRootLogin = "prohibit-password";
    /* just ensure no other login techs */
    settings.UsePAM = false;
  };
  security.polkit.enable = true;
  /* 
  su/sudo/ssh do not ask password
  same as initialHashedPassword
  */
  users.users.root.hashedPassword = "";
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


  users.users.ubuntu = {
    isNormalUser = true;
    home = "/home/ubuntu";
    extraGroups = [
      "wheel"
      "root"
    ];
    hashedPassword= "";
    # yeah, need to make it flake input (so can override it as needed)
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/PGg+j/Y5gP/e7zyMCyK+f0YfImZgKZ3IUUWmkoGtT dzmitry@nullstudios.xyz"
    ];
  };  
}