log="/var/log/install.log"
NAME=''
IP=''
USER='master'
MNT='/mnt'

usage() {
 echo "Usage: install.sh --name NAME --ip IP"
 exit 1
}

get_options() {
  opts=$(getopt --longoptions name:,ip: --name "install.sh" --options "" -- "$@")
  if [ "$?" -ne 0 ]; then
      usage
  fi
  eval set -- "$opts"

  while [[ $# -gt 0 ]]; do
     case "$1" in
        --name) NAME=$2 ; shift 2 ;;
        --ip) IP=$2 ; shift 2 ;;
        --) shift ;;
        *) echo "Internal error" ; exit 1 ;;
     esac
  done

  if [[ "$NAME" == '' ]]; then
    echo name is not provided
    usage
  fi

  if [[ "$IP" == '' ]]; then
    echo IP address is not provided
    usage
  fi
}

source environ.sh

_run_inside() {
  _run_cmd "$1" "arch-chroot $MNT $2"
}

get_options $@
_start_log
_run_cmd "parameters $NAME $IP" 'echo name=$NAME ip=$IP'

# checking internet availability
_run_cmd "pinging" 'ping -c 1 archlinux.org'

# getting list of archlinux package servers
_run_cmd "reflector" 'reflector --protocol https --save /etc/pacman.d/mirrorlist'

# creating disks
sfdisk -d /dev/sda &> /dev/null
if [ "$?" -eq 0 ]; then
  echo 'Disk already partitioned'
  exit 1
fi
_run_cmd "making partitions" 'echo -e ",0x800000,S\n,,L" | sfdisk /dev/sda'
_run_cmd "making file system" 'mkfs.ext4 /dev/sda2'
_run_cmd "mounting file system" 'mount /dev/sda2 /mnt'
_run_cmd "making swap" 'mkswap /dev/sda1'
_run_cmd "enbling swap" 'swapon /dev/sda1'

# initialiing pacman
_run_fore "Initiating pacman keys" 'pacman-key --init'
_run_fore "Initial pacman key setup" 'pacman-key --populate'

# installing packages
_run_fore "Installing packages" "pacstrap -K $MNT base linux grub sudo reflector"

# preparing fstab
_run_cmd "making fstab" "genfstab -U $MNT >> /mnt/etc/fstab"

# going inside
_run_inside "ensuring new root" 'pwd'
_run_inside "setting time zone" 'ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime'

#setting locale
_run_inside "locate configuration" 'sed "/en_US.UTF-8/s/^#//" -i /etc/locale.gen'
_run_inside "generating locale" 'locale-gen'
_run_cmd "configuring locale" "echo 'LANG=en_US.UTF-8' > $MNT/etc/locale.conf"
_run_inside "checking" 'ls -l /etc/locale.conf'
_run_cmd "machine name" "echo '$NAME' > $MNT/etc/hostname"

#configuring bootloader
_run_cmd "prepare boot dir" "mkdir $MNT/boot/grub"
_run_inside "configuring grub" "grub-mkconfig -o /boot/grub/grub.cfg"
_run_inside "making bootable" "grub-install /dev/sda"

#setting user
_run_inside "making user" "useradd -m $USER"
_run_cmd "setting password" "chpasswd -e -R $MNT < users.passwd"
_run_cmd "setting sudo" "echo '$USER ALL=(ALL:ALL) NOPASSWD:ALL' > $MNT/etc/sudoers.d/$USER"

#second stage installing scripts
_run_cmd "making install dir" "mkdir $MNT/root/config"
_run_cmd "copying install script" "cp config/configure.sh $MNT/root/config"
_run_cmd "setting install script" "chmod u+x $MNT/root/config/configure.sh"
_run_cmd "copying parameters" "cat config/params.sh | sed 's/{{IP}}/$IP/g' | sed 's/{{NAME}}/$NAME/g' > $MNT/root/config/params.sh"
_run_cmd "making install scripts" "cp environ.sh $MNT/root/config/environ.sh"
_run_cmd "network parameters"  "cat config/20-wired.network | sed 's/{{IP}}/$IP/g' > $MNT/root/config/20-wired.network"
_run_cmd "mount parameters"  "cp config/mnt-mobihome.mount $MNT/root/config/mnt-mobihome.mount"
_run_cmd "automount parameters"  "cp config/mnt-mobihome.automount $MNT/root/config/mnt-mobihome.automount"
_run_cmd "user parameters" "cp -r user.config $MNT/root/user.config"

echo "run /root/config/configure.sh after reboot"
echo "See log in " $log