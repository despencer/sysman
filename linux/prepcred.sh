#!/bin/sh

sudo cat /etc/shadow | awk 'BEGIN { FS=":"; } /master/ {print $1":"$2;}' > ../archiso/airootfs/root/users.passwd
