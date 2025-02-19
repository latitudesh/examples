Creates Ubuntu server and upgrades it into Nixos in place.

```
ssh ubuntu@103.88.232.157
[ubuntu@c2-small-x86-SAO2-nixos:~]$ uname -a
Linux c2-small-x86-SAO2-nixos 6.6.78 #1-NixOS SMP PREEMPT_DYNAMIC Mon Feb 17 08:40:43 UTC 2025 x86_64 GNU/Linux
```

More detailed:

1. Terraforms cheap Ubuntu server with SSH key.
2. SSH to server and runs script to upgrade Ubuntu into Nixos in place.
2.1. If there is SSH keys, script generates Nixos config whih uses these
2.1.1. Fully disables passwords authentication
3. Checks networking settings, and generates Nixos cofiguration (no DHCP).
4. Checks boot type and disk structure, and generates config.
5. Install nix and builds nixos boot/kernel/userland
6. Swaps Ubuntu to Nixos and reboots 

So we get Nixos on server resource.