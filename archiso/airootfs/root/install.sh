if ping -c 1 archlinux.org &> /dev/null
then
   echo "[+] Ping success"
else
   echo "[-] Ping fail"
   exit 1
fi

echo -e ",0x800000,S\n,,L" | sfdisk /dev/sda > /dev/null
echo "[+] partitions:"
sfdisk -d | grep start