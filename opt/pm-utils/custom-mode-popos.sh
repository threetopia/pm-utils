#!/bin/sh

ONLINE_STATUS=$(cat /sys/class/power_supply/AC/online)

# Find available backlight device
detect_backlight_path() {
    for dir in /sys/class/backlight/*; do
        [ -w "$dir/brightness" ] && echo "$dir" && return 0
    done
    return 1
}

# Set brightness level
set_display_brightness() {
    BACKLIGHT_PATH=$(detect_backlight_path)
    if [ -n "$BACKLIGHT_PATH" ]; then
        echo "$1" | sudo tee "$BACKLIGHT_PATH/brightness"
    else
        echo "No writable backlight path found." >&2
    fi
}

# Edit to meet your disire config
laptop_mode_ac() {
	sleep 1
        /bin/system76-power profile balanced
        set_display_brightness_acpi 29472
}

# Edit to meet your disire config
laptop_mode_battery() {
        sleep 1
        /bin/system76-power profile battery
	#set_display_brightness 24720
}

case $ONLINE_STATUS in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
esac

exit 0