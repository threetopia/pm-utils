#!/bin/bash

# Get power status: 1 = on AC, 0 = on battery
ONLINE_STATUS=$(cat /sys/class/power_supply/AC/online 2>/dev/null)

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
    echo "Detected CPU_VENDOR: '$CPU_VENDOR'"
    if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
        FILE="/sys/devices/system/cpu/intel_pstate/no_turbo"
    elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
        FILE="/sys/devices/system/cpu/cpufreq/boost"
    fi
    echo "$FILE"
    [ -w "$FILE" ] && echo "$1" | sudo tee "$FILE"
}

# Set max performance percentage
set_cpu_max_perf_pct() {
    if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
        FILE="/sys/devices/system/cpu/intel_pstate/max_perf_pct"
    elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
        FILE="/sys/devices/system/cpu/amd_pstate/max_perf_pct"
    fi
    [ -w "$FILE" ] && echo "$1" | sudo tee "$FILE"
}

# Set min performance percentage
set_cpu_min_perf_pct() {
    if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
        FILE="/sys/devices/system/cpu/intel_pstate/min_perf_pct"
    elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
        FILE="/sys/devices/system/cpu/amd_pstate/min_perf_pct"
    fi
    [ -w "$FILE" ] && echo "$1" | sudo tee "$FILE"
}

# Set GNOME power profile: performance, balanced, power-saver
set_power_profile() {
    /usr/bin/powerprofilesctl set "$1"
}

# Define your custom AC mode here
laptop_mode_ac() {
    sleep 1
    set_power_profile balanced
    set_cpu_noturbo 1
    set_cpu_max_perf_pct 100
    set_cpu_min_perf_pct 15
    set_display_brightness 24720  # Adjust value depending on device
}

# Define your custom battery mode here
laptop_mode_battery() {
    sleep 1
    set_power_profile power-saver
    set_cpu_noturbo 1
    set_cpu_max_perf_pct 50
    set_cpu_min_perf_pct 10
    set_display_brightness 19968  # Dim for power saving
}

# MAIN LOGIC
if [ "$ONLINE_STATUS" = "1" ]; then
    echo "Running on AC power"
    laptop_mode_ac
else
    echo "Running on battery"
    laptop_mode_battery
fi
