@echo off

REM find the VBoxManage executable
REM
where /r "%PROGRAMFILES%" VBoxManage /Q
if errorlevel 1 (echo VBoxManage not found & exit /b 2)
for /f "delims=" %%i in ('where /r "%PROGRAMFILES%" VBoxManage') do set vboxmanage=%%i

REM check the executable found
REM
"%vboxmanage%" --version > nul 2>&1
if errorlevel 1 (echo VBoxManage not found & exit /b 2)
for /f "delims=" %%i in ('"%vboxmanage%" --version') do set vboxversion=%%i
echo VBoxManage version %vboxversion%

