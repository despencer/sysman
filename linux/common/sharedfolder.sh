log="sharedfolder.log"
NAME="SF"
TARGET=$1

echo "Adding a permanent shared folder"
CPATH=$(dirname $(realpath "$0"))
source $CPATH/../environ.sh

_start_log
vboxmanage showvminfo $1 --machinereadable | grep "SharedFolderNameMachineMapping" | cut -d'"' -f 2 | while IFS= read -r FOLDER; do
  echo "Doing $FOLDER"
  ssh $TARGET "ls /mnt/$FOLDER" &> /dev/null
  if [ "$?" -ne 0 ]; then
     _run_cmd "$FOLDER Mount point make" "sudo mkdir /mnt/$FOLDER"
  else
     echo "Mount file /mnt/$FOLDER alredy exists, skipping"
  fi
  ssh $TARGET "ls /etc/systemd/system/mnt-$FOLDER.mount" &> /dev/null
  if [ "$?" -ne 0 ]; then
     _run_copy "$FOLDER Mount file copy" "$CPATH/config/mnt-folder.mount" "./mnt-folder.mount.template"
     _run_cmd "$FOLDER Mount file make" "cat ~/mnt-folder.mount.template | sed 's/{{FOLDER}}/$FOLDER/g' | sudo tee /etc/systemd/system/mnt-$FOLDER.mount"
     _run_cmd "$FOLDER Mount file clean up" "rm ~/mnt-folder.mount.template"
  else
     echo "Mount file /etc/systemd/system/mnt-$FOLDER.mount alredy exists, skipping"
  fi
  _run_cmd "systemctl reload" "sudo systemctl daemon-reload"
  _run_cmd "starting host mount" "sudo systemctl start mnt-$FOLDER.mount"
  ssh $TARGET "ls /etc/systemd/system/mnt-$FOLDER.automount" &> /dev/null
  if [ "$?" -ne 0 ]; then
     _run_copy "$FOLDER Automount file copy" "$CPATH/config/mnt-folder.automount" "./mnt-folder.automount.template"
     _run_cmd "$FOLDER Automount file make" "cat ~/mnt-folder.automount.template | sed 's/{{FOLDER}}/$FOLDER/g' | sudo tee /etc/systemd/system/mnt-$FOLDER.automount"
     _run_cmd "$FOLDER Automount file clean up" "rm ~/mnt-folder.automount.template"
  else
     echo "Automount file /etc/systemd/system/mnt-$FOLDER.automount alredy exists, skipping"
  fi
  _run_cmd "systemctl reload" "sudo systemctl daemon-reload"
  _run_cmd "enabling host automount" "sudo systemctl enable mnt-$FOLDER.automount"
done

echo "See log in $log"

