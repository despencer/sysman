#!/usr/bin/env bash
trap "exit" ERR
set -x

devsdx="${1:-/dev/sda}"
eth="${2:-enp0s3}"
if [[ ! -b "${devsdx}" || ! -d /sys/class/net/"${eth}" ]];
then
    echo "invalid arguments"
    exit
fi

if [[ -f /usr/bin/pacstrap ]];
then
    curl 'https://archlinux.org/mirrorlist/?country=DE&protocol=https&use_mirror_status=on' | sed 's/#Server/Server/g' > /etc/pacman.d/mirrorlist
    pacman -Syy
    parted -a optimal -s "${devsdx}" mklabel gpt mkpart primary 1MiB 100%
    mkfs.ext4 -O "^64bit" -F "${devsdx}1"
    mount "${devsdx}1" /mnt
    pacstrap /mnt base linux linux-firmware vim syslinux gptfdisk openssh
    genfstab /mnt > /mnt/etc/fstab
    arch-chroot /mnt bash <(cat "${0}") "${1}" "${2}"
    ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
    sync
    umount /mnt
    systemctl poweroff
else
    syslinux-install_update -iam
    sed -e "s/TIMEOUT 50/TIMEOUT 1/" -e "s@/dev/sda3@${devsdx}1@" -e "/archfallback/,+4 s/^/#/" -i /boot/syslinux/syslinux.cfg
    sed "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" -i /etc/locale.gen
    locale-gen
    locale > /etc/locale.conf
    echo -e "[Match]\nName=${eth}\n\n[Network]\nDHCP=ipv4" > /etc/systemd/network/20-wired.network
    mkdir -p /etc/systemd/resolved.conf.d
    echo -e "[Resolve]\nDNSSEC=false" > /etc/systemd/resolved.conf.d/dnssec.conf
    sed -e "s/^#PermitRootLogin.*/PermitRootLogin yes/" -e "s/^#PermitEmptyPasswords.*/PermitEmptyPasswords yes/" -i /etc/ssh/sshd_config
    systemctl enable sshd systemd-networkd systemd-resolved systemd-timesyncd
    pacman -S pkgfile mlocate linux-headers --noconfirm
    pkgfile -u
    updatedb
    pacman -S virtualbox-guest-utils-nox --noconfirm
    passwd -d root
    echo -e "vmshare\t\t/root/vmshare\t\tvboxsf\t\tdefaults\t\t0 0" >> /etc/fstab
    find /root -mindepth 1 -maxdepth 1 -print0 | xargs -0 rm -rf
fi
