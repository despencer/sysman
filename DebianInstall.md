# Debian installation without installer


## Media preparation

First of all, you need a computer with another Linux (btw, i use Arch) and access to HDD/SSD. You can attach HDD to your computer or use a live-USB.
I prefer to boot from live-USB with specially prepared ArchLinux.

The simplest way to obtain sources for media creation is to install **archiso** package. It comes with `/usr/share/archiso/configs` directories
having sources of two images: minimal(*baseline*) and installation (*releng*). I tried to use minimal image for some unknown for me reasons it hanged.
So I used *releng* and it was ok.

The best way to create installation media for Debian from Arch is to copy somewhere *releng* config and add a package `debootstrap` into the list
of packages for LiveUSB (file *packages.x86_64*).

Then run `sudo mkarchiso -v path_to_iso_sources` and after some time you will get *iso* file in the *out* directory.

Then you have to get Debian installation iso from [official repository](https://cdimage.debian.org/cdimage/archive).

Because i utilized TPLink USB WiFi dongle for temporary network connectivity, i also downloaded non-free firmware for this device
from [non-free debian repository](https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/archive).

Now we have three isos (Arch Linux Live USB and 2 Debians). We should put it all on a removable media (Flash USB) and made it bootable.
The best way is to plain copy from Arch Linux Live USB to the flash:
```
lsblk # get a list of block devices
sudo sp archlinux_iso /dev/sdX  # sdX - a reference to USB flash
```

After this we get magically two partitions on the flash and the rest of the flash is unpartitioned. We can create a third partition (`fdisk`),
format is with ext4 (`mkfs.ext4`) and copy there two Debian isos.

Voila, we not get the installation media.

## Primary installation

There are two ways to partition a HDD/SSD: an old one (**MBR**) and a new one (**GPT**). I prefer GPT but you have to create additional
partition: **EFI system partition** (for UEFI) or **BIOS boot partition** (for BIOS). So you have to create at least 3 partitions:
boot, system and swap.

One more note on disk partitioning. *fdisk* operates by 512-byte sectors and traditionally partitions are 1MiB aligne, so during partitioning
you have create partitions aligned on 2048 sectors. For boot partition, 1 MiB is enough.

So, after booting from ArchLinux LiveUSB we do partitioning and formatting:

```
# Partition the disk (sdX - usually sda)
# For gpt
fdisk /dev/sdX

# make file system
mkfs.ext4 /dev/sdX1

# make swap and enable it
mkswap /dev/sdX2
swapon /dev/sdX2
```

Then we need to get access to Debian installation media

```
MNT='/mnt'            # define a mount directory
DEBIAN='mnt/debian'    # define a directory for new Debian system

# in Live USB the filesystem is not persistent and we should create mount points for access to the new system disk and debian iso
mkdir $DEBIAN
mkdir $MNT/usb
mkdir $MNT/iso
mkdir $MNT/iso2

# mount new disk
mount /dev/sdX1 $DEBIAN

# mount a third partition of our USB
mount /dev/sdY3 $MNT/usb

# mount debian installation disks
mount -o loop $MNT/usb/debian_iso $MNT/iso
mount -o loop $MNT/usb/debian_firmware $MNT/iso2
```

Now everything is ready for create new system. Usually this part is performed by debian installer, but we will make it ourselves.

```
# define a Debian release
RELEASE='bullseye'

# creates baseline file structure and installs apt (package management system)
debootstrap --arch amd64 $RELEASE $DEBIAN file:$MNT/iso1

# sets the reference to the temporary package container:
echo "deb file:$MNT/iso/ $RELEASE main contrib > $MNT/etc/apt/sources.list
echo "deb file:$MNT/iso2/ $RELEASE non-free >> $MNT/etc/apt/sources.list
```

## Preparing system for a first boot

Let's dive into new installation. An **arch-chroot* is a wrapper for the traditional **chroot** and it also binds */dev*, */proc* and other
such directories. If you prefer **chroot** you have to do it yourself.

The booting is performed via BIOS. The command `check sys/firmware/efi` could help in identification that UEFI was used.

```
# Dive inside new installation
arch-chroot $DEBIAN

# define constants
MACHINE='a computer name'
USER='an username'

# Update aptitude internal cache
# flag allow-insecure-repositories is required for ISO sources
apt-get update --allow-insecure-repositories

# Check that both ISOs are in place
apt-cache policy

# Install bare minimal package to run a system
apt-get install locales sudo mc

# uncomment row in the /etc/locale.gen
sed "/en_US.UTF-8/s/^#//" -i /etc/locale.gen

# generating locale
locale-gen

# configuring locale
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# setting new born machine name
echo '$MACHINE' > /etc/hostname

# creating first user
useradd -m $USER

# setting password
passwd $USER

# configuring sudo for $USER
echo '$USER ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USER

# SUDO complains without this
echo '$MACHINE 127.0.0.1' >> /etc/hosts

# install linux kernel and boot packages
apt-get install linux-image-amd64 grub-pc


# configure GRUB for booting and install it into a special partition
grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/sdX
```

Now that's all and we can boot from the new installation, set up network and change package source list (file `/etc/apt/sources.list`)
to standard values:

```
deb https://deb.debian.org/debian $RELEASE main contrib non-free
deb-src https://deb.debian.org/debian $RELEASE main contrib non-free

deb https://security.debian.org/debian-security $RELEASE-security main contrib non-free
deb-src https://security.debian.org/debian-security $RELEASE-security main contrib non-free

deb https://deb.debian.org/debian $RELEASE-updates main contrib non-free
deb-src https://deb.debian.org/debian $RELEASE-updates main contrib non-free
```

Again, command `apt-cache policy` after `sudo apt-get update` should confirm that everything is ok.
