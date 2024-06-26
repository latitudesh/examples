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

# Add a user named packer
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