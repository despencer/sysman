log="hibernate.log"
NAME="HB"
TARGET=$1
SNAPSHOT="$HOME/vhome/hibernate/${TARGET}_hb.vid"

echo "Adding a hibernate formachine"
CPATH=$(dirname $(realpath "$0"))
source $CPATH/../environ.sh

make_swap() {
ssh $TARGET "mount | grep $DISKDEVICE" &> /dev/null
if [ "$?" -eq 0 ]; then
   echo "One partition is mounted"
   exit 1
else
   DISKDEVICE="/dev/$DISKDEVICE"
fi
ssh $TARGET "sudo sfdisk -d $DISKDEVICE" &> /dev/null
if [ "$?" -eq 0 ]; then
  echo "Disk $DISKDEVICE already partitioned"
  PT=$(ssh $TARGET "sudo sfdisk --part-type $DISKDEVICE 1")
  if [ "$PT" = '82' ]; then
     PARTITION="${DISKDEVICE}1"
  else
     echo "$DISKDEVICE1 is not a swap partition"
     exit 1
  fi
else
  ssh $TARGET "echo ',,S;' | sudo sfdisk $DISKDEVICE"
  PARTITION="${DISKDEVICE}1"
  ssh $TARGET sudo mkswap $PARTITION
fi
SWAPUUID=$(ssh $TARGET "sudo lsblk -no UUID $PARTITION")
if [ "$?" -ne 0 ]; then
  echo "Can't get UUID for $PARTITION"
  exit 1
fi
ssh $TARGET "grep $SWAPUUID /etc/fstab" &> /dev/null
if [ "$?" -eq 0 ]; then
   echo "Swap $SWAPUUID already in /etc/fstab"
else
   _run_cmd "configuring fstab" "echo -e '# $PARTITION\nUUID=$SWAPUUID none swap defaults 0 0\n' | sudo tee -a /etc/fstab"
fi 
echo "Using $PARTITION ($SWAPUUID) for hibernating"
}

_start_log
MEMORY=$(vboxmanage showvminfo $1 --machinereadable | grep "memory" | cut -d'=' -f 2)
echo "Memory size $MEMORY"
if [ -f $SNAPSHOT ]; then
   echo "Snapshot file $SNAPSHOT exists"
else
   echo "[+] creating HDD $SNAPSHOT"
   vboxmanage createhd --filename $SNAPSHOT --size=$MEMORY
fi
VMDISK=$(vboxmanage showvminfo $1 --machinereadable | grep "SATA-2-0" | cut -d'=' -f 2)
if [ "$VMDISK" = '"none"' ]; then
   echo "[+] attaching HDD to $TARGET"
   vboxmanage storageattach $TARGET --storagectl SATA --port 2 --device 0 --type hdd --medium $SNAPSHOT
else
   echo "Disk $VMDISK already present"
fi
DISKDEVICE=$(ssh $TARGET "lsblk -o HCTL,NAME -S | grep 2:0:0:0 | sed 's/.*  //g'")
if [ "$DISKDEVICE" == "" ]; then
   echo "Could not find SATA port 2"
   exit 1
fi
make_swap

ssh $TARGET "grep resume /etc/default/grub" &> /dev/null
if [ "$?" -eq 0 ]; then
   echo "Restore from hibernation is already set"
else
  _run_cmd "configuring grub" "sudo sed '/GRUB_CMDLINE_LINUX_DEFAULT/{s/quiet/quiet resume=UUID=$SWAPUUID/}' -i /etc/default/grub"
  _run_cmd "updating grub" "sudo grub-mkconfig -o /boot/grub/grub.cfg"
fi

#ssh $TARGET "grep resume /etc/mkinitcpio.conf" &> /dev/null
#if [ "$?" -eq 0 ]; then
#   echo "Hibernation mkinit hook is already set"
#else
#   _run_cmd "configuring mkinit" "sudo sed '/GRUB_CMDLINE_LINUX_DEFAULT/{s/quiet/quiet resume=UUID=$SWAPUUID/}' -i /etc/default/grub"
#   _run_cmd "reconfiguring mkint" "mkinitcpio -p linux"
#fi

echo "See log in $log"

