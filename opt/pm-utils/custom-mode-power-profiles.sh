#!/bin/sh

ONLINE_STATUS=$(cat /sys/class/power_supply/AC/online)

#cat /sys/class/backlight/acpi_video0/brightness
#4 to 15
set_display_brightness_acpi() {
        echo $1 | sudo tee /sys/class/backlight/intel_backlight/brightness
}

# Edit to meet your disire config
laptop_mode_ac() {
	sleep 1
        /usr/bin/powerprofilesctl set balanced
        set_display_brightness_acpi 2301
}

# Edit to meet your disire config
laptop_mode_battery() {
        sleep 1
        /usr/bin/powerprofilesctl set power-saver
	set_display_brightness_acpi 1188
}

case $ONLINE_STATUS in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
esac

exit 0