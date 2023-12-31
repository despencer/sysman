log="x11.log"

source ../environ.sh

_start_log
_run_fore "Updating package base" "sudo pacman -Sy"

echo "See log in $log"

