# Installing ZFS on Debian

```
# required packages
sudo apt-get install linux-headers-amd64
sudo apt-get install zfsutils-linux
```

*zfsutils-linux* will inform about license incompliance.

The test command `sudo modprobe zfs` didn't work with the message `modprobe: FATAL: Module zfs not found in directory /lib/modules/5.10.0-32-amd64`.
The Google suggested that the package *zfs-dkms* is missing. The command `sudo dpkg-reconfigure zfs-dkms` resulted with error
`Module build for kernel 5.10.0-32-amd64 was skipped since the kernel headers for this kernel does not seem to be installed`.

The problem was that package `linux-image` was of version *5.10-0.32* and `linux-headers` was of version *5.10-0.34*. The command
`sudo apt-get install linux-image-amd64` proposed for upgrade up to the *5.10-0.34* version. After a lot of compiling, the
command `sudo zfs version` reported:
```
zfs-2.0.3-9+deb11u1
zfs-kmod-2.0.3-9+deb11u1
```

# Playing with ZFS

First pool creation ```zpool create depot raidz [devices]```.

After `sudo zpool export depot` get message `no pools available`. Reboot and issue `sudo zpool import`. The result shows previously
exported pool. After command `sudo zpool import depot` the pool was ONLINE again.

To check issue command `sudo zpool scrub depot`.

Test: `sudo dd if=/dev/zero of=/dev/sdc1 bs=512 count=_a number_`


Command `sudo zpool get all depot` returns a list of properties.

Command `sudo zfs create depot/silo` makes a dataset and a filesystem.

Command `sudo zfs set mountpoint=/mnt/silo depot/silo` changes a mounting point.

Command `sudo zfs list -t snapshot` lists all snapshots

Command `sudo zpool destroy depot` destroys the pool.

sudo modprobe drivetemp
sensors
sudo smartctl -A /dev/sdb


urandom disk
status - no
scrub required clear
clear
file read ok

urandom
file read ok
status no problem
reboot
status - bad checksum
file read ok
file write
zpool clear - no data errors
scrub repaired
zpool clear

urandom
status no problem
resilver - nothing
scrub repaired and no clear was required
scrub again - no errors
file ok


# Setting ZFS as a backend for Windows file storages

Create a pool with options: ```zpool create -O acltype=posix -O xattr=on depot raidz [devices]``` and
```sudo zfs create -o casesensivity=insensitive -o aclmode=passthrough -o aclinherit=passthrough depo/silo```



TODO:

```
export
upgrade debian
import
zpool upgrade
```


