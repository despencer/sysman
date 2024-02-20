log="prod.log"
NAME="prod"

source ../environ.sh

_start_log
_run_fore "Updating package base" "sudo pacman -Sy"

# pulseview sigrok-cli sigrok-firmware-fx2lafw - logic analyzer packages with firmware
_run_fore "Installing packages" "sudo pacman -S python-pandas python-geopy --noconfirm"

echo "See log in $log"

