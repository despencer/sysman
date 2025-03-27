# WiFi access configuration

Usually, servers do not need WiFi because they connect via Ethernet. However, when I setup a server at home I have to use
WiFi via WiFi USB Dongle. 

Personally I utilized TP-Link *TL-WN822N* ver 6.0. with *rtl8192eu* chip.

Since WiFi is not originally a server technology, it is not installed by default. The other issue with WiFi is that it requires
authorization by a pass phrase and you have to store it somewhere.

I utilized NetworkManager for WiFi connectivity and it utilized *wpasupplicant* for actually managing WiFi. I think that *wpasupplicant*
could be used stand alone, but I did not try it. And for storing pass phrases I used a work-around solution by directly editing
`/etc/network/interfaces` configuration file.

Automatically generated WiFi interface has an ugly name of wlx supplemented by MAC-address, but I did not bother to rename it since it
was unique until I would not change the MAC-address of the dongle.

Below there are guidelines how to do it.

## Prerequisities and check-up

These packages are required:

`# network tools including ifconfig and ip
apt-get install net-tools

# lspci and lsusb for viewing what's connected
apt-get install pciutils
apt-get install usbutils

# realtek firmware drivers
apt-get install firmware-realtek`

## Checking
`# The USB WiFi adapter should be in the list
sudo lsusb

# lists all interfaces
# WiFi interface should be in the list as wlxMAC where MAC - the MAC address
ip link show`

The interface is not connected out of the box because accessing WiFi network requires SSID identification and password provision. However, we
can test the connection in manual mode.

You have to stop *wpa_supplicant* systemd service. With it up and running manual mode won't work. However, if you stop *wpa_supplicant* systemd service
and see the list of running services you will see it healthy running again. There is no miracle: *NetworkManager* service like a watchdog
practically immediatedly restarts the *wpa_supplicant*. So the right commands would be stopping both services:

`sudo systemctl stop NetworkManager
sudo systemctl stop wpa_supplicant`

And then we can run *wpa-cli* safely, see the available networks:
`sudo wpa-cli
>scan
>scan_results`

And finally connect:
`sudo nmcli device wifi connect $SSID password $WIFIPASSWD`

## Setting automatic connection

If everything is ok and you successfully connected to a WiFi access point, ypu have to convert PSK pass phrase into PSK pass code:
`wpa_passphrase $SSID $WIFIPASSWD`

File `/etc/network/interfaces` is configured to include all files from `interfaces.d`:
`source /etc/network/interfaces.d/*`

So I created a file named by my WiFi SSID in the `/etc/network/interfaces.d/` directory and put there the following:

`allow-hotplug wlx$MAC
iface wlx$MAC inet static
    wpa-ssid $SSID
    wpa-psk $PASSCODE
    address 192.168.0.$IP/24
    gateway 192.168.0.1`

And this configuration is activated at system startup.

There is a detailed explanation of `/etc/network/interfaces` on [StackExchange](https://unix.stackexchange.com/questions/128439/good-detailed-explanation-of-etc-network-interfaces-syntax)
and in [Debian Wiki](https://wiki.debian.org/WiFi/HowToUse).
