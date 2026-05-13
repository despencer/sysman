log="x11.log"
NAME="X11"
TARGET=$1

CPATH=$(dirname $(realpath "$0"))
source $CPATH/../environ.sh

_start_log
_run_fore "Updating package base" "sudo pacman -Sy"
_run_fore "Installing X11" "sudo pacman -S xorg-server openbox xorg-xinit xterm ttf-liberation xorg-fonts-misc --noconfirm"
_run_cmd "Setting xinit 1" "touch ~/.Xauthority"
_run_cmd "Setting xinit 2" "echo 'exec openbox' > ~/.xinitrc"
_run_copy "Configuring openbox" "$CPATH/openbox.config" "~/.config/openbox"

echo "See log in $log"

