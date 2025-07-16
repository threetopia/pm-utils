#!/bin/bash

# Get AC/battery status
AC_PATH=$(find /sys/class/power_supply/ -name "*AC*" | head -n1)
ONLINE_STATUS=$(cat "$AC_PATH/online")

### CPU FREQUENCY ###

set_cpu_governor() {
    for GOVFILE in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$GOVFILE" ] && echo "$1" | tee "$GOVFILE" > /dev/null
    done
}

set_scaling_max_freq() {
    for MAXFILE in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        [ -f "$MAXFILE" ] && echo "$1" | tee "$MAXFILE" > /dev/null
    done
}

set_scaling_min_freq() {
    for MINFILE in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
        [ -f "$MINFILE" ] && echo "$1" | tee "$MINFILE" > /dev/null
    done
}

set_boost() {
    local boost_path="/sys/devices/system/cpu/cpufreq/boost"
    [ -f "$boost_path" ] && echo "$1" | tee "$boost_path" > /dev/null
}

### DISK APM & SPINDOWN ###

set_hdparm_apm() {
    hdparm -B "$1" /dev/sda > /dev/null
}

set_hdparm_idletime() {
    hdparm -S "$1" /dev/sda > /dev/null
}

### BRIGHTNESS ###

set_display_brightness_acpi() {
    local brightness_path="/sys/class/backlight/acpi_video0/brightness"
    [ -f "$brightness_path" ] && echo "$1" | tee "$brightness_path" > /dev/null
}

### NOTIFY OSD ###

send_osd_notification() {
    local user=$(who | awk 'NR==1{print $1}')
    local display=$(w -h | awk '{print $2}' | grep -m1 ":")
    sudo -u "$user" DISPLAY="$display" notify-send "Power Management" "Power mode changed to $1"
}

### POWER MODES ###

laptop_mode_ac() {
    set_cpu_governor ondemand
    set_scaling_max_freq 2201000
    set_scaling_min_freq 500000
    set_boost 1
    set_hdparm_apm 127
    set_hdparm_idletime 241
    set_display_brightness_acpi 11
    #send_osd_notification AC
}

laptop_mode_battery() {
    set_cpu_governor conservative
    set_scaling_max_freq 1200000
    set_scaling_min_freq 500000
    set_boost 0
    set_hdparm_apm 127
    set_hdparm_idletime 120
    set_display_brightness_acpi 7
    #send_osd_notification Battery
}

### MAIN SWITCH ###

case "$ONLINE_STATUS" in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
    *) echo "Unknown power state: $ONLINE_STATUS" ;;
esac

exit 0
