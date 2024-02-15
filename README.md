# Arch Linux Installation

## My Arch Installation Process

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
pacman -S archlinux-keyring
```
4. Partitions (check if you need GPT or MBR with `cat /sys/firmware/efi/fw_platform_size`; if file not found use MBR)
    #### Case 1: GPT
    1. Create disk partitions :
    ```
    fdisk -l (show disks to get the name)
    fdisk /dev/sda (in my case it's sda)
    d (delete all previous partiotions)
    g (create new GPT table)
    n (create new partition for efi, end at +550M)
    t (change partition type to 1 - efi)
    n (create new partition for swap, end at +<RAM size>G)
    t (change partition type to 19 - swap)
    n (create new partition for root with the rest)
    w (write the changes)
    ```
    2. Format disk partitions
    ```
    mkfs.fat -F 32 /dev/sda1 (efi partition)
    mkswap /dev/sda2 (swap partition)
    mkfs.ext4 /dev/sda3 (root partition)
    ```
    3. Mount the filesystem and efi and enable swap
    ```
    mount /dev/sda3 /mnt
    mount --mkdir /dev/sda1 /mnt/boot
    swapon /dev/sda2
    ```
    #### Case 2: MBR
    1. Create disk partitions :
    ```
    fdisk -l (show disks to get the name)
    fdisk /dev/sda (in my case it's sda)
    d (delete all previous partiotions)
    o (create new DOS table)
    n (create new primary partition for /boot, end at +200M)
    n (create new primary partition for swap, end at +<1.5*RAMsize>G)
    n (create new primary partition for root)
    n (create new primary partition for /home)
    w (write the changes)
    ```
    2. Format disk partitions
    ```
    mkfs.ext4 /dev/sda1 (boot partition)
    mkswap /dev/sda2 (swap partition)
    mkfs.ext4 /dev/sda3 (root partition)
    mkfs.ext4 /dev/sda4 (home partition)
    ```
    3. Mount partitions and enable swap
    ```
    mount /dev/sda3 /mnt
    mount --mkdir /dev/sda1 /mnt/boot
    mount --mkdir /dev/sda4 /mnt/home
    swapon /dev/sda2
    ```
5. Install essential packages
```
pacstrap -K /mnt base linux linux-firmware
```
6. Fstab
```
genfstab -U /mnt >> /mnt/etc/fstab
```
7. Chroot
```
arch-chroot /mnt
```
8. Install more packages
```
pacman -S base-devel vim (basic linux stuff like gcc, which, etc + vim)
pacman -S networkmanager
```
9. Enable NetworkManager
```
systemctl enable NetworkManager
```
10. Set the time zone and enable network time synchronization
```
ln -sf /usr/share/zoneinfo/<Region>/<City> /etc/localtime
hwclock --systohc
timedatectl set-ntp true
```
11. Set Localization
```
vim /etc/locale.gen (find langs and uncomment them)
locale-gen
vim /etc/locale.conf (and add following)
LANG=en_US.UTF-8
LANGUAGE=en_US:en:C
LC_TIME=de_DE.UTF-8
```
12. Create a host name
```
echo <hostname> > /etc/hostname
```
13. Set root password
```
passwd
```
14. Create a user
```
useradd -m <username>
usermod -aG wheel,audio,video,optical,storage <username>
passwd <username>
```
15. Modify sudo config to allow users from wheel group needed access
```
visudo (find the line %wheel ALL=(ALL) ALL and uncomment it)
```
16. Install GRUB
    #### Case 1: GPT
    ```
    pacman -S grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
    Grub optionals:
    - dosfstools (if I have a windows partition and need to perform maintenance)
    - os-prober (in case I have multi-boot)
    - mtools (for manipulating files on MS-DOS disks, such as floppy disks or USB drives)
    #### Case 2: MBR
    ```
    pacman -S grub
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
    Grub optionals:
    - dosfstools (if I have a windows partition and need to perform maintenance)
    - os-prober (in case I have multi-boot)
    - mtools (for manipulating files on MS-DOS disks, such as floppy disks or USB drives)
17. Installation's done. Good to reboot now
```
exit
umount -R /mnt
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
pacman -S intel-ucode (or amd-ucode)
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
1. Edit /etc/hosts
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
2. Customize pacman (add colors)
```
sudo vim /etc/pacman.conf
<uncomment Color>
```
3. Install essentials
```
sudo pacman -S git make openssh
```
4. Run `./install` to install man, xorg, sddm and pipewire
5. Install my configs
    1. cd ~/.dotfiles
    2. make
    3. make install
    4. chsh -s /bin/zsh
    5. make apps
    6. reboot
