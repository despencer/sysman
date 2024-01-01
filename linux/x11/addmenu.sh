if [ -z "$2" ]; then
  echo 'Usage: addmenu name path'
  exit 1
fi

xml ed --inplace -N x='http://openbox.org/3.4/menu'  -i '/x:openbox_menu/x:menu/x:separator' -t elem -n 'item2' \
   -s '/x:openbox_menu/x:menu/item2' -t attr -n 'label' -v "$1" \
   -s '/x:openbox_menu/x:menu/item2' -t elem -n 'action' \
   -s '/x:openbox_menu/x:menu/item2/action' -t attr -n 'name' -v "Execute" \
   -s '/x:openbox_menu/x:menu/item2/action' -t elem -n 'execute' -v "$2" \
   -r '/x:openbox_menu/x:menu/item2' -v 'item' \
   ~/.config/openbox/menu.xml
