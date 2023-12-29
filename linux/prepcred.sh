#!/bin/sh

CFG=../archiso/airootfs/root/

sudo cat /etc/shadow | awk 'BEGIN { FS=":"; } /master/ {print $1":"$2;}' > $CFG/users.passwd

#the configs are not kept under git because they may contain confidential info
mkdir $CFG/user.config
mkdir $CFG/user.config/mc
cp ~/.config/mc/ini $CFG/user.config/mc/ini
cp ~/.config/mc/panels.ini $CFG/user.config/mc/panels.ini
cp ~/.gitconfig $CFG/user.config/.gitconfig
chmod 700 $CFG/user.config
chmod 700 $CFG/user.config/mc

