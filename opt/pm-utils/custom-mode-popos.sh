#!/bin/sh

# Get power status: 1 = on AC, 0 = on battery
ONLINE_STATUS=$(cat /sys/class/power_supply/ADP1/online 2>/dev/null)

# Detect CPU vendor
CPU_VENDOR=$(lscpu -J | jq -r '.lscpu[] | select(.field=="Vendor ID:") | .data')

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

# Disable turbo boost 
set_cpu_noturbo() {
    if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
        FILE="/sys/devices/system/cpu/intel_pstate/no_turbo"
    elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
        FILE="/sys/devices/system/cpu/cpufreq/boost"
    fi
    [ -w "$FILE" ] && echo "$1" | sudo tee "$FILE"
}

# Set GNOME power profile: performance, balanced, power-saver
set_power_profile() {
    /bin/system76-power profile "$1"
}

# Send OSD Notification
send_osd_notification() {
    local username=$(logname)  # get the user running the session
    local uid=$(id -u "$username")
    local display=$(w -hs | awk -v user="$username" '$1 == user { print $2; exit }')
    local dbus_address=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u "$username" gnome-session | head -n1)/environ | sed -e 's/DBUS_SESSION_BUS_ADDRESS=//' -e 's/\x0//g')

    if [ -z "$dbus_address" ]; then
        echo "⚠️  Could not determine DBUS session address. Notification skipped."
        return
    fi

    sudo -u "$username" DISPLAY=":$display" DBUS_SESSION_BUS_ADDRESS="$dbus_address" \
        notify-send "Power Management" "Power mode changed to $1"
}

# Edit to meet your disire config
laptop_mode_ac() {
	sleep 1
        set_cpu_noturbo 1
        set_power_profile balanced
        set_display_brightness 29472
}

# Edit to meet your disire config
laptop_mode_battery() {
        sleep 1
        set_cpu_noturbo 1
        set_power_profile battery
        set_display_brightness 19968
}

# MAIN LOGIC
if [ "$ONLINE_STATUS" = "1" ]; then
    echo "Running on AC power"
    laptop_mode_ac
    send_osd_notification "AC Mode"
else
    echo "Running on battery"
    laptop_mode_battery
    send_osd_notification "Battery Mode"
fi

exit 0