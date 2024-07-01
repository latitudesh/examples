# Almalinux 8

This example features deploying Almalinux, an Open Source and forever-free enterprise Linux distribution, governed and driven by the community, focused on long-term stability and a robust production grade platform. AlmaLinux OS is binary compatible with RHEL®.


Interactive Installation
------------------------

In this example the ipxe script [boot.ipxe](https://github.com/latitudesh/examples/blob/main/custom-image-almalinux-8/boot.ipxe) is used to load the Almalinux 8 installer, then you have to make the desirable choices to finish the installation in a similar way to a Installation ISO.

```bash
#!ipxe

ifopen net{{ INTERFACE_ID }}
set net{{ INTERFACE_ID }}/ip {{ PUBLIC_IP }}
set net{{ INTERFACE_ID }}/netmask {{ NETMASK }}
set net{{ INTERFACE_ID }}/gateway {{ PUBLIC_GW }}
set net{{ INTERFACE_ID }}/dns 8.8.8.8

kernel https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/images/pxeboot/vmlinuz inst.repo=https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/ initrd=initrd.img modprobe.blacklist=rndis_host net.ifnames=0 biosdevname=0 ip={{ PUBLIC_IP }}::{{ PUBLIC_GW }}:{{ NETMASK }}::eth{{ INTERFACE_ID }}:off:8.8.8.8
initrd https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/images/pxeboot/initrd.img
boot
```

More datails about iPXE deployments can be found at [custom-images](https://www.latitude.sh/docs/servers/custom-images).



Automatic Installation
----------------------

In this example the ipxe scrit [autoinstall-boot.ipxe](https://github.com/latitudesh/examples/blob/main/custom-image-almalinux-8/autoinstall-boot.ipxe) is used together with the config file [kickstart.ks](https://github.com/latitudesh/examples/blob/main/custom-image-almalinux-8/kickstart.ks) to provide a fully automated installation.


### kickstart.ks

```bash
# Use text install
text

# Install source
url --url='https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os'
repo --name="AppStream" --mirrorlist='https://mirrors.almalinux.org/mirrorlist/8/appstream'
repo --name="Extras" --mirrorlist='https://mirrors.almalinux.org/mirrorlist/8/extras'

eula --agreed

# Turn off after installation
reboot

# Do not start the Inital Setup app
firstboot --disable

# System language, keyboard and timezone
lang en_US.UTF-8
keyboard us
timezone UTC --isUtc

# Enable firewal, let SSH through
firewall --enabled --service=ssh
# Enable SELinux with default enforcing policy
selinux --enforcing

# Do not set up XX Window System
skipx

# Initial disk setup
# Use the first disk
ignoredisk --only-use=nvme0n1
# Place the bootloader on the Master Boot Record
bootloader --location=mbr --driveorder="nvme0n1" --timeout=1
# Wipe invalid partition tables
zerombr
# Erase all partitions and assign default labels
clearpart --all --initlabel
# Initialize the primary root partition with ext4 filesystem
part / --size=1 --grow --asprimary --fstype=ext4

# Set root password
rootpw --plaintext password

# Add a user named alma
user --groups=wheel --name=alma --password='#yourpasswordhere#' --plaintext --gecos='alma'

%post --erroronfail
# workaround anaconda requirements and clear root password
passwd -d root
passwd -l root
chage -d 0 alma

# Kickstart copies install boot options. Serial is turned on for logging with
# Packer which disables console output. Disable it so console output is shown
# during deployments
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/default/grub
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/default/grub
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/default/grub
sed -i 's/GRUB_ENABLE_BLSCFG=.*/GRUB_ENABLE_BLSCFG=false/g' /etc/default/grub

yum clean all

# Passwordless sudo for the user 'alma'
echo "alma ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/alma
chmod 440 /etc/sudoers.d/alma

#---- Optional - Install your SSH key ----
# mkdir -m0700 /home/alma/.ssh/
#
# cat <<EOF >/home/alma/.ssh/authorized_keys
# ssh-rsa <your_public_key_here> you@your.domain
# EOF
#
### set permissions
# chmod 0600 /home/alma/.ssh/authorized_keys
#
#### fix up selinux context
# restorecon -R /home/alma/.ssh/

%end

%packages
@Core
bash-completion
cloud-init
cloud-utils-growpart
rsync
tar
patch
yum-utils
grub2-efi-x64
shim-x64
grub2-efi-x64-modules
efibootmgr
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
-plymouth
# Remove ALSA firmware
-a*-firmware
# Remove Intel wireless firmware
-i*-firmware
%end
```

This file contains all needed data to finsh the installation. Be aware that parameter related to disk may change depending on the machine hardware. 

```bash
# Use the first disk
ignoredisk --only-use=nvme0n1
# Place the bootloader on the Master Boot Record
bootloader --location=mbr --driveorder="nvme0n1" --timeout=1
```

Replace the '#yourpasswordhere#' with the disired password at the line:

```bash
# Add a user named alma
user --groups=wheel --name=alma --password='#yourpasswordhere#' --plaintext --gecos='alma'
```

This file must be accesible from the machine you are deploying during boot, so you can use [gist](https://gist.github.com/) to make the file available.

### boot.ipxe

```bash
#!ipxe

ifopen net{{ INTERFACE_ID }}
set net{{ INTERFACE_ID }}/ip {{ PUBLIC_IP }}
set net{{ INTERFACE_ID }}/netmask {{ NETMASK }}
set net{{ INTERFACE_ID }}/gateway {{ PUBLIC_GW }}
set net{{ INTERFACE_ID }}/dns 8.8.8.8

kernel https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/images/pxeboot/vmlinuz inst.repo=https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/ inst.ks=https://github.com/latitudesh/examples/blob/main/custom-image-almalinux-8/kickstart.ks initrd=initrd.img modprobe.blacklist=rndis_host net.ifnames=0 biosdevname=0 ip={{ PUBLIC_IP }}::{{ PUBLIC_GW }}:{{ NETMASK }}::eth{{ INTERFACE_ID }}:off:8.8.8.8
initrd https://repo.almalinux.org/almalinux/8/BaseOS/x86_64/os/images/pxeboot/initrd.img
boot
```

Note that the ipxe.script have a reference to kickstart.ks file at parameter *inst.ks=*, this parameter should be updated with the kickstart file url.

At the end of installation you will be able access the machine via ssh, using the user *(alma)* and passaword configured in the kickstart file.

