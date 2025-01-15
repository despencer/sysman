# BIOS/UEFI information gathering

Run *dmidecode* to get BIOS information

## How to detect UEFI
- Check */sys/firmware/efi* existance
- Run *efibootmgr*. If there is no UEFI you get *EFI variables are not supported on this system*