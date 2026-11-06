pacman -S samba
# cp ?? /etc/samba/smb.conf
sudo systemctl enable smb
sudo systemctl enable nmb
sudo systemctl start smb
sudo systemctl start nmb
sudo smbpasswd -a master
sudo pdbedit -L -v
