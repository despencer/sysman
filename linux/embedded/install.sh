log="x11.log"
NAME="embedded"

source ../environ.sh

_start_log
_run_fore "Updating package base" "sudo pacman -Sy"
_run_fore "Installing packages" "sudo pacman -S usbutils --noconfirm"

echo "See log in $log"

