@echo off

REM find the VBoxManage executable
REM
where /r "%PROGRAMFILES%" VBoxManage /Q
if errorlevel 1 (echo VBoxManage not found & exit /b 3)
for /f "delims=" %%i in ('where /r "%PROGRAMFILES%" VBoxManage') do set vboxmanage=%%i

REM check the executable found
REM
"%vboxmanage%" --version > nul 2>&1
if errorlevel 1 (echo VBoxManage not found & exit /b 3)
for /f "delims=" %%i in ('"%vboxmanage%" --version') do set vboxversion=%%i
echo VBoxManage version %vboxversion%

REM getting parameters
for /f "delims=" %%i in ('""%vboxmanage%" list systemproperties | findstr "machine folder""') do set vboxpath=%%i
for /f "tokens=2,3 delims=:" %%a in ("%vboxpath%") do (set vboxpath=%%a:%%b)
for /f "delims= " %%a in ("%vboxpath%") do (set vboxpath=%%a)

echo VM default path: %vboxpath%

REM checking parameters
REM
if "%1"=="" (
echo Please provide parameters:
echo   machine name
echo   --hdd size in Gb [optional]
echo   --memory size in Mb [optional]
echo   --usb on/off [optional]
exit /b 2
)

SET vm_name=%1
shift

SET vm_hdd=50000
SET vm_memory=4096
SET vm_ostype=ArchLinux_64
SET vm_isopath="C:\home\distribs\linux\archlinux-2021.12.01-x86_64.iso"
SET vm_usb=off
:getops
if /I %~1 == --hdd (set vm_hdd=%2000& shift) else (
 if /I %~1 == --memory (set vm_memory=%2& shift) else (
  if /I %~1 == --usb (set vm_usb=%2& shift) else (
 echo Unknown parameter %1& exit /b 2)))
shift
if not (%1)==() goto getops

echo Making %vm_name%
echo os type: %vm_ostype% 
echo Hdd size: %vm_hdd%Mb
echo Memory: %vm_memory%Mb
echo iso: %vm_isopath%
echo usb: %vm_usb%

REM checking machine existance
"%vboxmanage%" showvminfo %vm_name% 2>&1 | findstr VBOX_E_OBJECT_NOT_FOUND > nul
if %errorlevel% NEQ 0 (
    echo vm %vm_name% already exists, first delete it
    echo command: vboxmanage unregistervm %vm_name% --delete
    exit /B 1
)

echo [+] creating vm
"%vboxmanage%" createvm --name %vm_name% --ostype ArchLinux_64 --register > nul
echo [+] configuring basic vm settings
"%vboxmanage%" modifyvm %vm_name% --memory %vm_memory% --vram 64 --ioapic on --acpi on --chipset ich9 --largepages on --usb %vm_usb%> nul
echo [+] configuring network
"%vboxmanage%" modifyvm %vm_name% --nictype1 82540EM --nic1 bridged --bridgeadapter1 em1 > nul
echo [+] configuring booting
"%vboxmanage%" modifyvm %vm_name% --boot1 disk --boot2 dvd --boot3 none --boot4 none > nul
echo [+] creating hdd
"%vboxmanage%" createhd --filename %vboxpath%\%vm_name%\%vm_name%.vdi -size %vm_hdd% > nul
echo [+] creating SATA
"%vboxmanage%" storagectl %vm_name% --name SATA --add sata --controller IntelAHCI --portcount 4 > nul
echo [+] attaching hdd
"%vboxmanage%" storageattach %vm_name% --storagectl SATA --port 0 --device 0 --type hdd --medium %vboxpath%\%vm_name%\%vm_name%.vdi > nul
echo [+] attaching iso
"%vboxmanage%" storageattach %vm_name% --storagectl SATA --port 3 --device 0 --type dvddrive --medium %vm_isopath% > nul
echo [+] adding share
"%vboxmanage%" sharedfolder add %vm_name% --name mobihome --hostpath "C:\home" > nul
echo All done
