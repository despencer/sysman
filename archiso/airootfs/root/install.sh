
log="/var/log/install.log"

_start_log() {
 rm $log &> /dev/null
 date > $log
 hwclock -r >> $log
 timedatectl status >> $log
}

_run_cmd() {
 echo "================= $1" >> $log
 eval "$2" &>> $log
 if [ "$?" -ne 0 ]; then
    echo "Fail $2 with $?"
    echo "See log in " $log
    exit 1
 else
    echo "[+] $1"
 fi
}

_run_fore() {
 echo "================= $1" >> $log
 eval "$2"
 if [ "$?" -ne 0 ]; then
    echo "Fail $2 with $?"
    exit 1
 else
    echo "[+] $1"
 fi
}

_run_inside() {
  _run_cmd "$1" "arch-chroot /mnt $2"
}

_start_log

# checking internet availability
_run_cmd "pinging" 'ping -c 1 archlinux.org'

# getting list of archlinux package servers
_run_cmd "reflector" 'reflector --save /etc/pacman.d/mirrorlist'

# creating disks
sfdisk -d /dev/sda &> /dev/null
if [ "$?" -eq 0 ]; then
  echo 'Disk already partitioned'
  exit 1
fi
_run_cmd "Checking partitions" 'sfdisk -d /dev/sda'
_run_cmd "making partitions" 'echo -e ",0x800000,S\n,,L" | sfdisk /dev/sda'
_run_cmd "making file system" 'mkfs.ext4 /dev/sda2'
_run_cmd "mounting file system" 'mount /dev/sda2 /mnt'
_run_cmd "making swap" 'mkswap /dev/sda1'
_run_cmd "enbling swap" 'swapon /dev/sda1'

# initialiing pacman
_run_fore "Initiating pacman keys" 'pacman-key --init'
_run_fore "Initial pacman key setup" 'pacman-key --populate'

# installing packages
_run_fore "Installing packages" 'pacstrap -K /mnt base linux'

# preparing fstab
_run_cmd "making fstab" 'genfstab -U /mnt >> /mnt/etc/fstab'

# going inside
_run_inside "ensuring new root" 'pwd'
_run_inside "setting time zone" 'ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime'

#setting locale
_run_inside "locate configuration" 'sed "/en_US.UTF-8/s/^#//" -i /etc/locale.gen'
_run_inside "generating locale" 'locale-gen'
_run_inside "configuring locale" 'echo "LANG=en_US.UTF-8" > /etc/locale.conf'
_run_inside "checking" 'ls -l /etc/locale.conf'

echo "See log in " $log