@echo off
if NOT EXIST %HOMEDRIVE%%HOMEPATH%\vmshare (
    echo shared vm folder %HOMEDRIVE%%HOMEPATH%\vmshare does not exist
    exit /B
)
if NOT EXIST %HOMEDRIVE%%HOMEPATH%\arch.iso (
    echo arch linux iso %HOMEDRIVE%%HOMEPATH%\arch.iso does not exist
    exit /B
)
where vboxmanage > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo vboxmanage command not found
    exit /B
)
vboxmanage showvminfo arch 2>&1 | findstr VBOX_E_OBJECT_NOT_FOUND > nul
if %ERRORLEVEL% NEQ 0 (
    echo arch vm already exists
    exit /B
)
echo [+] creating vm
vboxmanage createvm --name arch --ostype ArchLinux_64 --register > nul
echo [+] configuring basic vm settings
vboxmanage modifyvm arch --memory 4096 --vram 128 --graphicscontroller vmsvga --rtcuseutc on --paravirtprovider none --cpus 2 --defaultfrontend headless --audio none --natpf1 ssh,tcp,,22,,22 > nul
echo [+] creating hdd
vboxmanage createhd --filename "%HOMEDRIVE%%HOMEPATH%\VirtualBox VMs\arch\arch.vdi" --size 32000 --format VDI > nul 2>&1
echo [+] creating ide
vboxmanage storagectl arch --name IDE --add ide --controller PIIX4 > nul
echo [+] attaching arch iso
vboxmanage storageattach arch --storagectl IDE --port 1 --device 0 --type dvddrive --medium "%HOMEDRIVE%%HOMEPATH%\arch.iso" > nul
echo [+] creating sata
vboxmanage storagectl arch --name SATA --add sata --controller IntelAhci --portcount 1 > nul
echo [+] attaching hdd
vboxmanage storageattach arch --storagectl SATA --port 0 --device 0 --type hdd --medium "%HOMEDRIVE%%HOMEPATH%\VirtualBox VMs\arch\arch.vdi" > nul
echo [+] adding shared folder
vboxmanage sharedfolder add arch --name vmshare --hostpath "%HOMEDRIVE%%HOMEPATH%\vmshare" > nul
echo [+] starting vm
vboxmanage startvm arch > nul
echo [+] waiting for bootscreen
timeout 16 > nul
echo [+] sending enter
vboxmanage controlvm arch keyboardputscancode 1C 9C > nul
echo [+] waiting for boot to finish
timeout 64 > nul
echo [+] sending inputs to start setup script
{scancodes}
echo [+] waiting for setup to finish
:loop
timeout 4 > nul
vboxmanage showvminfo arch | findstr /c:"powered off (since" > nul
if %ERRORLEVEL% NEQ 0 GOTO loop
timeout 8 > nul
echo [+] ejecting cd
vboxmanage storageattach arch --storagectl IDE --port 1 --device 0 --type dvddrive --medium emptydrive
timeout 4 > nul
echo [+] starting vm
vboxmanage startvm arch > nul
echo [+] waiting for boot to finish
timeout 128 > nul
echo [+] creating setup snapshot
vboxmanage snapshot arch take setup > nul 2>&1
timeout 4 > nul
echo [+] shutting down vm
vboxmanage controlvm arch poweroff > nul 2>&1
timeout 4 > nul 2>&1
echo [+] restoring setup snapshot
vboxmanage snapshot arch restore setup > nul 2>&1
