log="x11.log"
NAME="embedded"

source ../environ.sh

_start_log
_run_fore "Updating package base" "sudo pacman -Sy"

# pulseview sigrok-cli sigrok-firmware-fx2lafw - logic analyzer packages with firmware
_run_fore "Installing packages" "sudo pacman -S usbutils pulseview sigrok-cli sigrok-firmware-fx2lafw --noconfirm"
_run_fore "Adding menu" "../x11/addmenu.sh PulseView /usr/bin/pulseview"

echo "See log in $log"

