cd /root/config

source ./params.sh
source ./environ.sh

_run_cmd "enabling network" "systemctl enable systemd-networkd.service"
_run_cmd "configure network" "cp 20-wired.network /etc/systemd/network"
_run_cmd "starting network" "systemctl start systemd-networkd.service"
_run_cmd "pinging" 'ping -c 1 192.168.100.1'
_run_cmd "enabling resolving" "systemctl enable systemd-resolved.service"
_run_cmd "starting resolving" "systemctl start systemd-resolved.service"
_run_fore "getting packages" "pacman -S git mc --noconfirm"
_run_cmd "copy user config" "cp -r user.config /home/$USER/.config"
_run_cmd "setting config access" "chown -R $USER:$USER /home/$USER/.config"
_run_cmd "moving git config" "mv /home/$USER/.config/.gitconfig /home/$USER/.gitconfig"

echo "See log in " $log