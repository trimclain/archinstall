# Arch Installer

## My Arch Installation Process (reference for automation)

1. Live boot from USB with Arch ISO and choose first install option
2. Connect to WiFi:
```
iwctl
device list (get device name: ex. wlan0)
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <network-name>
exit
ip link (should show wlan0 state as UP)
```
3. Install keyring to avoid possible errors in pacstrap
```
pacman -Sy archlinux-keyring`
```
4. Create disk partitions:
```
fdisk -l (show disks to get the name)
fdisk /dev/sda (in my case it's sda)
d (delete all previous partiotions)
g (create new gpt table)
n (create new partition for efi, end at +550M)
t (change partition type to 1 - efi)
n (create new partition for swap, end at +<RAM size>G)
t (change partition type to 19 - swap)
n (create new partition for root with the rest)
w (write the changes)
```
5. Format disk partitions
```
mkfs.fat -F 32 /dev/sda1 (efi partition)
mkswap /dev/sda2 (swap partition)
mkfs.ext4 /dev/root_partition (root partition)
```
6. Mount the filesystem and efi and enable swap
```
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
```
7. Install essential packages
```
pacstrap -K /mnt base linux linux-firmware
```
8. Fstab
```
genfstab -U /mnt >> /mnt/etc/fstab
```
9. Chroot
```
arch-chroot /mnt
```
10. Install more packages
```
pacman -S base-devel vim (basic linux stuff like gcc, which, etc + vim)
pacman -S networkmanager
```
11. Enable NetworkManager
```
systemctl enable NetworkManager
```
12. Set the time zone
```
ln -sf /usr/share/zoneinfo/<Region>/<City> /etc/localtime
hwclock --systohc
```
13. Set Localization
```
vim /etc/locale.gen (find langs and uncomment them)
locale-gen
vim /etc/locale.conf (and add following)
LANG=en_US.UTF-8
LANGUAGE=en_US:en:C:ru_RU
LC_TIME=de_DE.UTF-8
```
14. Create a host name
```
echo <hostname> > /etc/hostname
```
15. Set root password
```
passwd
```
16. Create a user
```
useradd -m <username>
usermod -aG wheel,audio,video,optical,storage <username>
passwd <username>
```
17. Modify sudo config to allow users from wheel group needed access
```
visudo (find the line %wheel ALL=(ALL) ALL and uncomment it)
```
18. Install GRUB
```
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```
Grub optionals:
dosfstools (if I have a windows partition and need to perform maintenance)
os-prober (in case I have multi-boot)
mtools (for manipulating files on MS-DOS disks, such as floppy disks or USB drives)
19. Installation's done. Good to reboot now
```
exit
umount -a (not sure this is necessary)
shutdown now (remove usb stick and start the pc)
```
## Post-Install Tweaks
### Security
0. Login as root and connect to WiFi
```
nmtui
```
1. Install microcode for the CPU (https://wiki.archlinux.org/title/Microcode)
```
pacmans -S intel-ucode (or amd-ucode)
grub-mkconfig -o /boot/grub/grub.cfg
```
2. Enforce a delay of 4 seconds after a failed login attempt
```
vim /etc/pam.d/system-login (add following line)
auth optional pam_faildelay.so delay=4000000
```
3. Edit /etc/security/faillock.conf to lock out users after 5 attemts and to persist the locks after reboot
```
vim /etc/security/faillock.conf (update following lines)
deny = 5
dir = /var/lib/faillock
```

### The rest
1. Install the rest
```
pacman -S git htop man-db
```
2. Edit /etc/hosts
```
sudo vim /etc/hosts (add following lines)

# The following lines are desirable for IPv4 capable hosts
127.0.0.1	localhost
127.0.1.1	<hostname>

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```
3. Customize pacman (add colors)
```
vim /etc/pacman.com
<uncomment Color>
```
4. Install paru
```
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```
5. Install the X.org display server
```
pacman -S xorg-server xorg-xinit
```
6. Install the LightDM login manager
```
pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings (this installs python aswell :D)
systemctl enable lightdm
```
NOTE: Usually users start XORG either manually using xinit or via display manager (my case)
In first case you can edit xinitrc, in second case xprofile

7. Install a terminal
```
paru -S kitty
```
8. Install my configs
