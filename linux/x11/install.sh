log="x11.log"
NAME="X11"

source ../environ.sh

_start_log
_run_fore "Updating package base" "sudo pacman -Sy"
_run_fore "Installing X11" "sudo pacman -S xorg-server openbox xorg-xinit xterm ttf-liberation --noconfirm"
_run_cmd "Setting xinit" "echo 'exec openbox' > ~/.xinitrc"
_run_cmd "Configuring openbox" "cp -r openbox.config ~/.config/openbox"

echo "See log in $log"

