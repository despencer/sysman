# Hints on openbox configuration

In order to use `Menu` key for key bindings, you have to specify it in hexadecimal (e.g. Menu-m minimizes window) in rc.xml file:
```
<keybind key="C-0x87 m">
   <action name="Iconify"/>
</keybind>
```

In order to start programs from a tty put `export DISPLAY=:0` into a `.bashrc` file.

To switch key board layout, do the following:
- install `python-xdg` packet
- change `exec openbox` to `exec openbox-session` in `.xinit.rc` file
- create executable file `~/.config/openbox/autostart`
- put `setxkbmap -layout "us,ru" -option "ctrl_shift_toggle" &` into autostart
