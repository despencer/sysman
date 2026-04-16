# VirtualBox installation in the Arch Linux

Create a dedicated user *vbox* for controlling and running Virtual Machines (VM). `-m` option makes the system to create a home directory. Then
set the password for the *vbox* user.
```
useradd -m vbox
passwd vbox

```

Then we need a two partitions: one for VMs and virtual disks and second for the shared resource. Let them be `/dev/sda3` and `/dev/sdb1` respectively.
Make file systems on them:
```
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sdb1
```

Make the mounting points, mount the newly created file systems and generate records in `/etc/fstab` for permanent mounting. `-U` options makes
UUID address of partition instead of /dev/sdX. And don't forget to edit `/etc/fstab` for changing mount directories from `/` to `/home/vbox/XXX`.
```
mkdir /home/vbox/vms
mkdir /home/vbox/vhome
mount /dev/sda3 /home/vbox/vms
mount /dev/sdb1 /home/vbox/vhome
genfstab -U /home/vbox/vms >> /etc/fstab
genfstab -U /home/vbox/vhome >> /etc/fstab
```

Make a reboot and ensure that those partitions are correctly mounted. Then we should make these partitions available for the `vbox` user:
```
chown -R vbox:vbox /home/vbox/vms
chown -R vbox:vbox /home/vbox/vhome
```
Again reboot, login as vbox and ensure that those partiotions are available.

Then install package `virtualbox` and select base package `virtualbox-host-modules-arch`.

For a fresh VirtualBox installation you should set some parameters (this should be done as `vbox` user):

Set directory for our VMs:
```VBoxManage setproperty machinefolder /home/vbox/vms```

Set a usually not-used key `Menu key` as `Host key` for switching from guest to host:
```VBoxManage setextradata global "GUI/Input/HostKeyCombination" 65383```

Set guest management toolbar at the top of the window:
```VBoxManage setextradata global "GUI/MiniToolBarAlignment" "Top"```

## Access from VirtualBox to a raw partitions

Sometimes a virtual machine has to access a lot of raw data. For example, your run a database inside virtualbox. One solution is to make a dedicated
partition in a host system and provide it as a raw partition to a virtualbox. Beforehands, a `vbox` user should have access to raw disks:
```sudo usermod -a -G disk vbox```
and then create a VMDK proxy disk:
```vboxmanage createmedium disk --filename <path.vmdk> --format=VMDK --variant RawDisk --property RawDrive=/dev/sdXX```
and attach it a usual way:
```vboxmanage storageattach <vmname> --storagectl SATA --port 1 --device 0 --type hdd --medium <path.vmdk>
