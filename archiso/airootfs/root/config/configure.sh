cd /root/config

source ./params.sh
source ./environ.sh

_log_section "Configuring Network"
_run_cmd "enabling network" "systemctl enable systemd-networkd.service"
_run_cmd "configure network" "cp 20-wired.network /etc/systemd/network"
_run_cmd "starting network" "systemctl start systemd-networkd.service"
_run_cmd "pinging" 'ping -c 1 192.168.100.1'
_run_cmd "enabling resolving" "systemctl enable systemd-resolved.service"
_run_cmd "starting resolving" "systemctl start systemd-resolved.service"

_log_section "Disable unnecessary modules"
_run_cmd "disabling i2c_piix4" "echo 'blacklist i2c_piix4' >> /etc/modprobe.d/modprobe.conf"

_log_section "Getting packages"
_run_fore "getting packages" "pacman -S git mc virtualbox-guest-utils terminus-font xmlstarlet openssh --noconfirm"

_log_section "Configuring VirtualBox guest"
_run_cmd "enabling vbox" "systemctl enable vboxservice.service"
_run_cmd "starting vbox" "systemctl start vboxservice.service"
SCREENSIZE=$(VBoxControl --nologo guestproperty get '/Custom/ScreenSize' | cut -d ' ' -f 2)
echo "Screen Size $SCREENSIZE" >> $log

_log_section "Configuring booting"
_run_cmd "reconfiguring mkint" "mkinitcpio -p linux"
_run_cmd "configuring grub video" 'sed "/GRUB_CMDLINE_LINUX_DEFAULT/{s/quiet/quiet video=$SCREENSIZE/}" -i /etc/default/grub'
_run_cmd "saving grub config" "grub-mkconfig -o /boot/grub/grub.cfg"

_log_section "Configuring SSH"
_run_cmd "configure SSH daemon" "cp 99-local.conf /etc/ssh/sshd_config.d"
_run_cmd "configure SSH key" "mkdir /home/$USER/.ssh"
_run_cmd "copy SSH key" "cp trakey.pub /home/$USER/.ssh/authorized_keys"
_run_cmd "setting SSH access" "chown -R $USER:$USER /home/$USER/.ssh"
_run_cmd "systemctl reload" "systemctl daemon-reload"
_run_cmd "starting SSH" "systemctl start sshd"
_run_cmd "enabling SSH at start" "systemctl enable sshd"

_log_section "Configuring user environment"
_run_cmd "configuring vconsole" 'echo "FONT=ter-c24n" >> /etc/vconsole.conf'
_run_cmd "copy user config" "cp -r ../user.config /home/$USER/.config"
_run_cmd "setting config access" "chown -R $USER:$USER /home/$USER/.config"
_run_cmd "moving git config" "mv /home/$USER/.config/.gitconfig /home/$USER/.gitconfig"

#_run_cmd "configure host mount" "cp mnt-mobihome.mount /etc/systemd/system"
#_run_cmd "systemctl reload" "systemctl daemon-reload"
#_run_cmd "starting host mount" "systemctl start mnt-mobihome.mount"
#_run_cmd "configure host auto-mount " "cp mnt-mobihome.automount /etc/systemd/system"
#_run_cmd "systemctl reload" "systemctl daemon-reload"
#_run_cmd "enabling host automount" "systemctl enable mnt-mobihome.automount"

echo "Please reboot"
echo "See log in " $log