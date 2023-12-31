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
vboxmanage controlvm arch keyboardputscancode 12 92 2E AE 23 A3 18 98 39 B9 2A 23 A3 AA 05 85 1F 9F 2A 17 97 AA 2A 1E 9E AA 2A 1E 9E AA 2A 1E 9E AA 2A 1E 9E AA 2A 1E 9E AA 2A 1E 9E AA 2A 1E 9E AA 2A 2E AE AA 35 B5 03 83 2A 2F AF AA 2A 2F AF AA 30 B0 2A 11 91 AA 35 B5 30 B0 2A 31 B1 AA 23 A3 2A 20 A0 AA 2A 0D 8D AA 08 88 26 A6 0A 8A 2D AD 26 A6 30 B0 20 A0 32 B2 30 B0 2C AC 2A 14 94 AA 14 94 2A 31 B1 AA 23 A3 16 96 2A 22 A2 AA > nul
vboxmanage controlvm arch keyboardputscancode 30 B0 2A 18 98 AA 07 87 2A 2E AE AA 14 94 17 97 06 86 2A 11 91 AA 2A 15 95 AA 2A 12 92 AA 32 B2 2A 20 A0 AA 2A 18 98 AA 2A 19 99 AA 25 A5 2A 16 96 AA 2A 24 A4 AA 11 91 2A 15 95 AA 26 A6 31 B1 17 97 2A 14 94 AA 2A 2E AE AA 2A 12 92 AA 17 97 2A 11 91 AA 2A 10 90 AA 26 A6 2A 22 A2 AA 2A 31 B1 AA 24 A4 15 95 2A 2D AD AA 35 B5 2F AF 2A 16 96 AA 2A 2C AC AA 2A 10 90 AA 2A 2F AF AA 03 83 > nul
vboxmanage controlvm arch keyboardputscancode 2C AC 2A 21 A1 AA 22 A2 07 87 2A 2D AD AA 23 A3 04 84 21 A1 2A 23 A3 AA 23 A3 09 89 31 B1 17 97 2A 32 B2 AA 02 82 21 A1 2A 32 B2 AA 2A 32 B2 AA 30 B0 1E 9E 04 84 17 97 1F 9F 2A 31 B1 AA 2A 12 92 AA 12 92 0A 8A 23 A3 26 A6 24 A4 2A 15 95 AA 21 A1 2A 18 98 AA 2A 2E AE AA 2A 32 B2 AA 10 90 2A 2E AE AA 2A 23 A3 AA 2A 2E AE AA 24 A4 2A 2D AD AA 2A 17 97 AA 2A 13 93 AA 2C AC 2A 25 A5 AA > nul
vboxmanage controlvm arch keyboardputscancode 07 87 2F AF 2A 30 B0 AA 2D AD 2A 15 95 AA 20 A0 1F 9F 2A 32 B2 AA 02 82 22 A2 2A 17 97 AA 2A 23 A3 AA 2A 21 A1 AA 14 94 06 86 2A 11 91 AA 2A 15 95 AA 1E 9E 35 B5 21 A1 2A 20 A0 AA 35 B5 06 86 2A 17 97 AA 2D AD 2D AD 2A 22 A2 AA 31 B1 2A 12 92 AA 13 93 2D AD 2A 2D AD AA 2A 32 B2 AA 0B 8B 2A 10 90 AA 2A 24 A4 AA 20 A0 08 88 06 86 08 88 1F 9F 2C AC 23 A3 13 93 18 98 12 92 03 83 35 B5 > nul
vboxmanage controlvm arch keyboardputscancode 21 A1 25 A5 2A 16 96 AA 17 97 31 B1 2E AE 04 84 2E AE 2A 12 92 AA 30 B0 2A 15 95 AA 2A 20 A0 AA 2A 21 A1 AA 2A 10 90 AA 2A 24 A4 AA 2A 12 92 AA 2D AD 09 89 24 A4 16 96 2A 20 A0 AA 19 99 15 95 21 A1 1F 9F 25 A5 2E AE 2A 26 A6 AA 16 96 02 82 2A 19 99 AA 2A 2E AE AA 32 B2 2A 12 92 AA 14 94 2A 2F AF AA 15 95 24 A4 05 85 06 86 2A 13 93 AA 2A 2E AE AA 2A 22 A2 AA 2A 30 B0 AA 2A 1F 9F AA > nul
vboxmanage controlvm arch keyboardputscancode 35 B5 2F AF 35 B5 0A 8A 13 93 05 85 2A 23 A3 AA 2A 26 A6 AA 2A 16 96 AA 2A 1E 9E AA 07 87 2A 1E 9E AA 21 A1 2A 24 A4 AA 31 B1 25 A5 2A 21 A1 AA 25 A5 20 A0 2A 24 A4 AA 13 93 2A 16 96 AA 2A 1F 9F AA 22 A2 2A 24 A4 AA 11 91 32 B2 2A 13 93 AA 2A 31 B1 AA 17 97 20 A0 13 93 2A 2C AC AA 2A 25 A5 AA 2A 1E 9E AA 2A 1F 9F AA 19 99 16 96 25 A5 2A 22 A2 AA 10 90 2A 30 B0 AA 14 94 02 82 2A 25 > nul
vboxmanage controlvm arch keyboardputscancode A5 AA 2A 26 A6 AA 2A 17 97 AA 2A 2F AF AA 2A 0D 8D AA 2A 23 A3 AA 08 88 2A 2F AF AA 2A 17 97 AA 30 B0 2A 26 A6 AA 16 96 2A 21 A1 AA 2A 1E 9E AA 08 88 2A 1F 9F AA 25 A5 2A 32 B2 AA 2A 10 90 AA 2A 11 91 AA 2E AE 06 86 2A 32 B2 AA 08 88 2A 2F AF AA 0A 8A 18 98 2D AD 2C AC 2A 15 95 AA 2A 2C AC AA 2A 25 A5 AA 09 89 2A 16 96 AA 2A 26 A6 AA 13 93 2A 2C AC AA 24 A4 2A 2E AE AA 10 90 2A 14 > nul
vboxmanage controlvm arch keyboardputscancode 94 AA 09 89 2A 2F AF AA 2A 17 97 AA 2A 2C AC AA 2A 16 96 AA 06 86 26 A6 2A 2E AE AA 2A 11 91 AA 2E AE 21 A1 35 B5 2A 1F 9F AA 1E 9E 19 99 2A 22 A2 AA 2A 18 98 AA 08 88 2A 18 98 AA 20 A0 21 A1 19 99 07 87 0A 8A 13 93 2A 16 96 AA 04 84 26 A6 10 90 10 90 2A 10 90 AA 10 90 19 99 16 96 03 83 1F 9F 14 94 05 85 04 84 2A 21 A1 AA 2A 2C AC AA 2E AE 23 A3 2E AE 2A 11 91 AA 17 97 20 A0 2E AE > nul
vboxmanage controlvm arch keyboardputscancode 2A 15 95 AA 07 87 12 92 2A 2F AF AA 2A 19 99 AA 18 98 2A 12 92 AA 31 B1 1F 9F 2A 2E AE AA 24 A4 23 A3 2D AD 2A 19 99 AA 2A 26 A6 AA 23 A3 2A 23 A3 AA 2A 32 B2 AA 0B 8B 1E 9E 2A 20 A0 AA 12 92 0A 8A 12 92 03 83 2A 10 90 AA 26 A6 09 89 2A 1E 9E AA 2A 17 97 AA 05 85 16 96 09 89 21 A1 2A 11 91 AA 2A 16 96 AA 2A 10 90 AA 18 98 35 B5 25 A5 04 84 24 A4 2A 24 A4 AA 14 94 2A 13 93 AA 2E AE > nul
vboxmanage controlvm arch keyboardputscancode 2A 12 92 AA 2A 19 99 AA 30 B0 2A 26 A6 AA 08 88 20 A0 20 A0 32 B2 2A 19 99 AA 24 A4 2A 2E AE AA 2A 17 97 AA 18 98 2A 24 A4 AA 10 90 2A 22 A2 AA 10 90 31 B1 2A 1F 9F AA 26 A6 2A 12 92 AA 2A 1E 9E AA 1F 9F 11 91 21 A1 1F 9F 26 A6 1E 9E 14 94 2A 2E AE AA 2D AD 2A 21 A1 AA 23 A3 2A 1E 9E AA 2A 2F AF AA 24 A4 16 96 15 95 21 A1 2A 14 94 AA 13 93 2A 16 96 AA 23 A3 23 A3 2A 26 A6 AA 2A 31 > nul
vboxmanage controlvm arch keyboardputscancode B1 AA 2A 21 A1 AA 17 97 2A 15 95 AA 2A 2D AD AA 07 87 17 97 2A 31 B1 AA 2A 32 B2 AA 2D AD 16 96 2A 32 B2 AA 21 A1 2A 11 91 AA 07 87 2A 13 93 AA 15 95 26 A6 20 A0 18 98 2A 13 93 AA 30 B0 14 94 11 91 19 99 1F 9F 2A 22 A2 AA 09 89 2A 10 90 AA 2A 19 99 AA 21 A1 2D AD 2D AD 2A 22 A2 AA 31 B1 1F 9F 19 99 03 83 2A 2C AC AA 2E AE 0A 8A 14 94 2A 12 92 AA 32 B2 22 A2 1F 9F 21 A1 2A 1F 9F AA > nul
vboxmanage controlvm arch keyboardputscancode 08 88 2A 19 99 AA 2A 2D AD AA 2A 1E 9E AA 2A 20 A0 AA 2A 26 A6 AA 04 84 2A 2F AF AA 21 A1 2A 2D AD AA 2A 0D 8D AA 2A 20 A0 AA 2A 13 93 AA 12 92 04 84 2D AD 31 B1 2A 17 97 AA 2A 26 A6 AA 2A 1F 9F AA 2A 16 96 AA 23 A3 2A 1F 9F AA 20 A0 2A 26 A6 AA 26 A6 2A 1F 9F AA 25 A5 21 A1 23 A3 2A 16 96 AA 2A 21 A1 AA 2A 15 95 AA 10 90 2D AD 2A 24 A4 AA 2A 17 97 AA 2C AC 2D AD 2A 2E AE AA 24 A4 > nul
vboxmanage controlvm arch keyboardputscancode 03 83 26 A6 2A 25 A5 AA 19 99 08 88 2A 17 97 AA 13 93 03 83 22 A2 2A 31 B1 AA 19 99 2A 1F 9F AA 2A 32 B2 AA 04 84 32 B2 25 A5 2A 20 A0 AA 2A 23 A3 AA 2A 2F AF AA 2A 25 A5 AA 26 A6 2A 32 B2 AA 2A 16 96 AA 2A 30 B0 AA 07 87 2A 16 96 AA 2A 19 99 AA 08 88 1E 9E 10 90 26 A6 19 99 2F AF 2A 11 91 AA 03 83 2A 25 A5 AA 2A 21 A1 AA 05 85 2A 10 90 AA 26 A6 16 96 1E 9E 25 A5 10 90 02 82 07 87 > nul
vboxmanage controlvm arch keyboardputscancode 2A 0D 8D AA 2A 2D AD AA 11 91 0A 8A 09 89 35 B5 2A 24 A4 AA 1E 9E 2A 17 97 AA 14 94 30 B0 35 B5 11 91 2E AE 35 B5 12 92 2C AC 21 A1 2A 12 92 AA 07 87 2A 26 A6 AA 2A 30 B0 AA 14 94 0A 8A 19 99 2C AC 2A 25 A5 AA 2A 26 A6 AA 09 89 22 A2 2A 0D 8D AA 17 97 2D AD 2A 24 A4 AA 30 B0 2D AD 13 93 14 94 2A 11 91 AA 09 89 19 99 23 A3 2A 25 A5 AA 30 B0 26 A6 2A 30 B0 AA 2A 11 91 AA 2D AD 2A 2F > nul
vboxmanage controlvm arch keyboardputscancode AF AA 13 93 06 86 2A 31 B1 AA 2A 15 95 AA 02 82 2A 32 B2 AA 2A 10 90 AA 16 96 2A 20 A0 AA 2A 16 96 AA 2A 2F AF AA 2A 26 A6 AA 19 99 0A 8A 2A 22 A2 AA 2A 2D AD AA 2A 2F AF AA 2A 19 99 AA 2A 11 91 AA 12 92 2A 26 A6 AA 2A 15 95 AA 13 93 2E AE 07 87 1E 9E 2A 15 95 AA 0B 8B 32 B2 0B 8B 2A 31 B1 AA 2A 12 92 AA 2C AC 2A 12 92 AA 2A 2E AE AA 2A 1E 9E AA 2A 14 94 AA 2A 2F AF AA 0B 8B 2A 30 > nul
vboxmanage controlvm arch keyboardputscancode B0 AA 20 A0 2A 19 99 AA 1E 9E 2A 25 A5 AA 19 99 0B 8B 31 B1 2A 1F 9F AA 2A 1E 9E AA 23 A3 2E AE 2A 2F AF AA 20 A0 2A 26 A6 AA 2A 19 99 AA 2A 2E AE AA 22 A2 2A 31 B1 AA 2A 22 A2 AA 03 83 17 97 2A 25 A5 AA 2A 24 A4 AA 2A 2C AC AA 2A 31 B1 AA 2A 26 A6 AA 2A 15 95 AA 2A 2F AF AA 2A 20 A0 AA 2A 15 95 AA 2A 12 92 AA 10 90 2A 16 96 AA 2A 17 97 AA 2E AE 2A 21 A1 AA 13 93 17 97 2A 13 93 AA > nul
vboxmanage controlvm arch keyboardputscancode 2A 30 B0 AA 2A 2C AC AA 21 A1 2F AF 2A 19 99 AA 02 82 2A 15 95 AA 2F AF 30 B0 14 94 0A 8A 22 A2 2A 2C AC AA 2A 0D 8D AA 2A 23 A3 AA 35 B5 21 A1 32 B2 23 A3 2A 12 92 AA 2E AE 23 A3 12 92 2A 26 A6 AA 05 85 08 88 2A 13 93 AA 2A 0D 8D AA 35 B5 2A 19 99 AA 2A 2D AD AA 0B 8B 2A 10 90 AA 05 85 2A 20 A0 AA 09 89 2A 22 A2 AA 03 83 2A 1F 9F AA 02 82 2A 19 99 AA 2A 2E AE AA 24 A4 25 A5 2A 11 > nul
vboxmanage controlvm arch keyboardputscancode 91 AA 15 95 05 85 13 93 35 B5 0A 8A 12 92 22 A2 10 90 2A 11 91 AA 2A 19 99 AA 35 B5 2A 2E AE AA 23 A3 31 B1 07 87 10 90 2A 1E 9E AA 2D AD 0B 8B 2A 10 90 AA 2A 2F AF AA 04 84 02 82 2A 2D AD AA 2A 13 93 AA 2A 22 A2 AA 07 87 2A 32 B2 AA 25 A5 2C AC 21 A1 13 93 26 A6 1E 9E 12 92 03 83 2A 23 A3 AA 2A 17 97 AA 12 92 13 93 26 A6 08 88 2A 2D AD AA 2D AD 0B 8B 12 92 35 B5 2A 18 98 AA 2A 21 > nul
vboxmanage controlvm arch keyboardputscancode A1 AA 35 B5 2A 10 90 AA 31 B1 14 94 25 A5 08 88 35 B5 03 83 2A 30 B0 AA 2A 12 92 AA 2A 14 94 AA 2A 19 99 AA 2A 14 94 AA 2A 2F AF AA 2A 12 92 AA 26 A6 18 98 1F 9F 2A 30 B0 AA 2A 13 93 AA 02 82 19 99 03 83 1E 9E 2A 32 B2 AA 2A 22 A2 AA 2A 1F 9F AA 2A 23 A3 AA 11 91 02 82 02 82 24 A4 20 A0 08 88 25 A5 0A 8A 24 A4 2A 0D 8D AA 03 83 2A 30 B0 AA 0A 8A 2A 15 95 AA 2A 2D AD AA 21 A1 2A 2D > nul
vboxmanage controlvm arch keyboardputscancode AD AA 2A 10 90 AA 17 97 2A 2D AD AA 06 86 2A 19 99 AA 2E AE 2A 26 A6 AA 21 A1 2A 1F 9F AA 26 A6 2A 25 A5 AA 31 B1 2A 17 97 AA 30 B0 2A 20 A0 AA 2F AF 20 A0 2A 1E 9E AA 2A 26 A6 AA 21 A1 2A 2D AD AA 12 92 2A 24 A4 AA 08 88 13 93 2A 12 92 AA 15 95 2A 25 A5 AA 05 85 19 99 09 89 35 B5 2F AF 21 A1 2A 14 94 AA 02 82 2A 2F AF AA 2A 14 94 AA 2A 2F AF AA 07 87 0A 8A 2A 31 B1 AA 18 98 23 A3 > nul
vboxmanage controlvm arch keyboardputscancode 08 88 30 B0 2A 14 94 AA 2A 14 94 AA 05 85 2E AE 2E AE 35 B5 32 B2 08 88 2A 32 B2 AA 2A 23 A3 AA 19 99 2A 2F AF AA 2A 30 B0 AA 2A 18 98 AA 12 92 18 98 2E AE 2A 2D AD AA 2A 11 91 AA 20 A0 2A 26 A6 AA 2A 2C AC AA 2A 15 95 AA 2A 20 A0 AA 2A 2F AF AA 23 A3 02 82 2A 32 B2 AA 07 87 15 95 2A 11 91 AA 2A 2F AF AA 30 B0 15 95 25 A5 22 A2 12 92 2A 21 A1 AA 2A 2D AD AA 2A 32 B2 AA 20 A0 18 98 > nul
vboxmanage controlvm arch keyboardputscancode 31 B1 08 88 2A 13 93 AA 15 95 35 B5 26 A6 09 89 0A 8A 32 B2 26 A6 2A 25 A5 AA 26 A6 2A 21 A1 AA 19 99 09 89 14 94 12 92 05 85 2A 13 93 AA 2A 2E AE AA 2A 24 A4 AA 21 A1 2A 16 96 AA 2F AF 19 99 24 A4 1F 9F 20 A0 2A 16 96 AA 32 B2 2F AF 06 86 09 89 2A 19 99 AA 11 91 2A 2E AE AA 25 A5 03 83 19 99 04 84 2A 20 A0 AA 2A 16 96 AA 19 99 09 89 2A 21 A1 AA 2A 0D 8D AA 2A 2F AF AA 2A 25 A5 AA > nul
vboxmanage controlvm arch keyboardputscancode 2A 14 94 AA 04 84 07 87 23 A3 2A 13 93 AA 0A 8A 06 86 2A 15 95 AA 2A 17 97 AA 14 94 03 83 2A 24 A4 AA 04 84 2A 22 A2 AA 21 A1 2A 19 99 AA 15 95 14 94 13 93 14 94 08 88 03 83 17 97 2A 1F 9F AA 05 85 2A 0D 8D AA 03 83 2A 17 97 AA 03 83 0B 8B 35 B5 07 87 20 A0 2A 2E AE AA 0A 8A 32 B2 0A 8A 31 B1 19 99 2A 10 90 AA 2A 16 96 AA 21 A1 2A 17 97 AA 35 B5 2A 0D 8D AA 2A 2D AD AA 2A 1F 9F AA > nul
vboxmanage controlvm arch keyboardputscancode 02 82 07 87 2A 22 A2 AA 15 95 18 98 08 88 2A 2C AC AA 2A 12 92 AA 2A 26 A6 AA 2A 11 91 AA 2A 26 A6 AA 2A 1F 9F AA 11 91 15 95 20 A0 0B 8B 2A 2D AD AA 1F 9F 25 A5 07 87 16 96 26 A6 05 85 2E AE 16 96 05 85 04 84 02 82 2A 20 A0 AA 13 93 19 99 2E AE 0B 8B 2A 19 99 AA 12 92 09 89 2A 19 99 AA 2A 26 A6 AA 15 95 2A 22 A2 AA 18 98 2A 21 A1 AA 06 86 26 A6 10 90 2A 1F 9F AA 2A 25 A5 AA 05 85 > nul
vboxmanage controlvm arch keyboardputscancode 0B 8B 22 A2 2F AF 13 93 16 96 14 94 2A 19 99 AA 2A 18 98 AA 2E AE 23 A3 2A 10 90 AA 2A 1F 9F AA 24 A4 2A 10 90 AA 2A 2D AD AA 2A 22 A2 AA 20 A0 2A 31 B1 AA 2A 16 96 AA 2A 11 91 AA 2A 15 95 AA 2A 16 96 AA 2A 24 A4 AA 35 B5 08 88 08 88 2A 24 A4 AA 2A 2C AC AA 2A 12 92 AA 09 89 06 86 2A 18 98 AA 03 83 35 B5 05 85 15 95 2A 19 99 AA 1F 9F 2A 24 A4 AA 2E AE 2A 25 A5 AA 2A 0D 8D AA 2A 32 > nul
vboxmanage controlvm arch keyboardputscancode B2 AA 1E 9E 2A 16 96 AA 2E AE 2A 14 94 AA 2A 2F AF AA 23 A3 32 B2 2A 16 96 AA 2A 31 B1 AA 2A 11 91 AA 1F 9F 2E AE 1E 9E 19 99 11 91 19 99 2A 26 A6 AA 2A 16 96 AA 2A 24 A4 AA 2F AF 2A 2D AD AA 22 A2 2A 24 A4 AA 05 85 2A 2E AE AA 07 87 2A 14 94 AA 09 89 2A 19 99 AA 35 B5 23 A3 2A 15 95 AA 05 85 2A 21 A1 AA 2A 23 A3 AA 2A 21 A1 AA 20 A0 03 83 19 99 2C AC 16 96 32 B2 18 98 2A 2F AF AA > nul
vboxmanage controlvm arch keyboardputscancode 30 B0 2A 18 98 AA 2A 18 98 AA 07 87 24 A4 21 A1 2A 32 B2 AA 2A 0D 8D AA 2D AD 2A 24 A4 AA 31 B1 2A 2E AE AA 30 B0 12 92 25 A5 14 94 17 97 2A 25 A5 AA 19 99 13 93 2A 2E AE AA 2A 11 91 AA 2A 11 91 AA 2A 0D 8D AA 2A 19 99 AA 2A 15 95 AA 2A 16 96 AA 11 91 2A 1F 9F AA 20 A0 2D AD 10 90 35 B5 04 84 2A 20 A0 AA 2A 18 98 AA 19 99 0B 8B 2F AF 2A 14 94 AA 06 86 1E 9E 1E 9E 09 89 2A 2C AC AA > nul
vboxmanage controlvm arch keyboardputscancode 2A 2F AF AA 19 99 2A 25 A5 AA 2A 31 B1 AA 14 94 2E AE 14 94 23 A3 2A 10 90 AA 13 93 30 B0 2A 15 95 AA 0A 8A 2A 20 A0 AA 2A 2C AC AA 20 A0 10 90 19 99 13 93 32 B2 2A 19 99 AA 09 89 2A 22 A2 AA 2A 22 A2 AA 2A 19 99 AA 24 A4 10 90 0B 8B 09 89 2A 14 94 AA 2A 22 A2 AA 2A 15 95 AA 2A 12 92 AA 19 99 23 A3 2A 24 A4 AA 35 B5 21 A1 21 A1 32 B2 2A 18 98 AA 08 88 22 A2 2A 1E 9E AA 03 83 2A 15 > nul
vboxmanage controlvm arch keyboardputscancode 95 AA 22 A2 11 91 2A 30 B0 AA 11 91 2A 1E 9E AA 2A 1E 9E AA 39 B9 2A 2B AB AA 39 B9 30 B0 1E 9E 1F 9F 12 92 07 87 05 85 39 B9 0C 8C 20 A0 39 B9 2A 2B AB AA 39 B9 2C AC 2E AE 1E 9E 14 94 39 B9 2A 34 B4 AA 39 B9 1F 9F 12 92 14 94 16 96 19 99 34 B4 1F 9F 23 A3 39 B9 2A 08 88 AA 2A 08 88 AA 39 B9 2E AE 23 A3 32 B2 18 98 20 A0 39 B9 16 96 2A 0D 8D AA 2D AD 39 B9 1F 9F 12 92 14 94 16 96 > nul
vboxmanage controlvm arch keyboardputscancode 19 99 34 B4 1F 9F 23 A3 39 B9 2A 08 88 AA 2A 08 88 AA 39 B9 34 B4 35 B5 1F 9F 12 92 14 94 16 96 19 99 34 B4 1F 9F 23 A3 1C 9C > nul
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
