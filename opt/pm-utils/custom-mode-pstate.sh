#!/bin/bash

# Detect CPU vendor
CPU_VENDOR=$(lscpu | awk -F: '/Vendor ID/ {gsub(/^[ \t]+/, "", $2); print $2}')

# Detect power supply status (0 = battery, 1 = AC)
AC_PATH=$(find /sys/class/power_supply/ -name "*AC*" | head -n1)
ONLINE_STATUS=$(cat "$AC_PATH/online")

### FUNCTIONS ###

set_cpu_governor() {
    for CPUGOVERNOR in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$CPUGOVERNOR" ] && echo "$1" | tee "$CPUGOVERNOR" > /dev/null
    done
}

# Intel-specific
set_cpu_maxpct() {
    local path="/sys/devices/system/cpu/intel_pstate/max_perf_pct"
    [ -f "$path" ] && echo "$1" | tee "$path" > /dev/null
}

set_cpu_minpct() {
    local path="/sys/devices/system/cpu/intel_pstate/min_perf_pct"
    [ -f "$path" ] && echo "$1" | tee "$path" > /dev/null
}

set_cpu_noturbo() {
    if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
        local path="/sys/devices/system/cpu/intel_pstate/no_turbo"
        [ -f "$path" ] && echo "$1" | tee "$path" > /dev/null
    elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
        local path="/sys/devices/system/cpu/cpufreq/boost"
        [ -f "$path" ] && echo "$((1 - $1))" | tee "$path" > /dev/null  # AMD boost is 1=enabled
    fi
}

# Disk settings
set_hdparm_apm() {
    hdparm -B "$1" /dev/sda > /dev/null
}

set_hdparm_idletime() {
    hdparm -S "$1" /dev/sda > /dev/null
}

# Display brightness (acpi_video0 as default)
set_display_brightness_acpi() {
    local backlight_path="/sys/class/backlight/acpi_video0/brightness"
    [ -f "$backlight_path" ] && echo "$1" | tee "$backlight_path" > /dev/null
}

# Desktop notification (optional)
send_osd_notification() {
    local user=$(who | awk 'NR==1{print $1}')
    local display=$(w -h | awk '{print $2}' | grep -m 1 ":")
    sudo -u "$user" DISPLAY="$display" notify-send "Power Management" "Power mode changed to $1"
}

### POWER PROFILES ###

laptop_mode_ac() {
    set_cpu_governor powersave
    set_cpu_maxpct 100
    set_cpu_minpct 26
    set_cpu_noturbo 0
    # set_hdparm_apm 127
    # set_hdparm_idletime 241
    set_display_brightness_acpi 11
    send_osd_notification AC
}

laptop_mode_battery() {
    set_cpu_governor powersave
    set_cpu_maxpct 50
    set_cpu_minpct 26
    set_cpu_noturbo 1
    # set_hdparm_apm 127
    # set_hdparm_idletime 120
    set_display_brightness_acpi 7
    send_osd_notification Battery
}

### MAIN LOGIC ###

case "$ONLINE_STATUS" in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
    *) echo "Unknown AC status: $ONLINE_STATUS" ;;
esac

exit 0
