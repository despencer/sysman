log="x11.log"
NAME="embedded"

source ../environ.sh

_start_log
_run_fore "Updating package base" "sudo pacman -Sy"

# pulseview sigrok-cli sigrok-firmware-fx2lafw - logic analyzer packages with firmware
_run_fore "Installing packages" "sudo pacman -S usbutils pulseview sigrok-cli sigrok-firmware-fx2lafw --noconfirm"
_run_fore "Adding menu" "../x11/addmenu.sh PulseView /usr/bin/pulseview"

# development packages
_run_fore "Installing dev packages" "sudo pacman -S make cmake arm-none-eabi-gcc arm-none-eabi-newlib libopencm3 dfu-util --noconfirm"

# electronics tools packages
_run_fore "Installing dev tools" "sudo pacman -S kicad kicad-library --noconfirm"
_run_fore "Adding menu" "../x11/addmenu.sh Kicad /usr/bin/kicad"

# dev tools packages
_run_fore "Installing dev tools" "sudo pacman -S python-jinja python-yaml --noconfirm"
_run_fore "Installing freertos" "git clone https://github.com/FreeRTOS/FreeRTOS-Kernel ~/.local/lib/freertos"

# access rights
_run_cmd "serial access" "sudo usermod -a -G uucp $USER"

echo "See log in $log"

