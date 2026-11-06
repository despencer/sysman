# Fixing the font problem

If the vconsole font is switched back at startup, it is because NVidia driver loads later. A following lifehack helps to restart service:

Create a file `/etc/udev/rules.d/96-fb-vconsole.rules` with the following:
```
ACTION=="add", SUBSYSTEM=="graphics", KERNEL=="fb*", RUN+="/usr/bin/systemctl restart systemd-vconsole-setup.service"
```