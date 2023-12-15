log="/var/log/install.log"

_start_log() {
 rm $log &> /dev/null
 date > $log
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

_start_log
_run_cmd "pinging" 'ping -c 1 archlinux.org'
_run_cmd "making partitions" 'echo -e ",0x800000,S\n,,L" | sfdisk /dev/sda'
_run_cmd "making file system" 'mkfs.ext4 /dev/sda2'
_run_cmd "mounting file system" 'mount /dev/sda2 /mnt'
_run_cmd "making swap" 'mkswap /dev/sda1'
_run_cmd "enbling swap" 'swapon /dev/sda1'

echo "See log in " $log