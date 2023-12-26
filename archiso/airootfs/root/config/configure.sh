source ./params.sh
source ./environ.sh

_run_cmd "enabling network" "systemctl enable systemd-networkd.service"
_run_cmd "configure network" "cp 20-wired.network /etc/systemd/network"
_run_cmd "starting network" "systemctl start systemd-networkd.service"
_run_cmd "enabling resolving" "systemctl enable systemd-resolved.service"
_run_cmd "starting resolving" "systemctl start systemd-resolved.service"
_run_cmd "getting packages" "pacman -S git mc --noconfirm"

echo "See log in " $log