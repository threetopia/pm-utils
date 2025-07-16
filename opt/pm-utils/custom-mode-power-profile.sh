#!/bin/bash

ONLINE_STATUS=$(cat /sys/class/power_supply/AC/online)
CPU_VENDOR=$(lscpu | awk -F: '/Vendor ID/ {gsub(/^[ \t]+/, "", $2); print $2}')

# GNOME Power Profiles
set_power_profile() {
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set "$1"
    fi
}

# Brightness (adjust path as needed)
set_display_brightness() {
    BRIGHTNESS_PATH="/sys/class/backlight/intel_backlight/brightness"
    [ -w "$BRIGHTNESS_PATH" ] && echo "$1" | sudo tee "$BRIGHTNESS_PATH" > /dev/null
}

# Intel P-state
set_intel_pstate_param() {
    PARAM_PATH="/sys/devices/system/cpu/intel_pstate/$1"
    [ -w "$PARAM_PATH" ] && echo "$2" | sudo tee "$PARAM_PATH" > /dev/null
}

# AMD / cpufreq fallback
set_cpu_governor() {
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$f" ] && echo "$1" | sudo tee "$f" > /dev/null
    done
}

set_scaling_freq() {
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_"$1"_freq; do
        [ -f "$f" ] && echo "$2" | sudo tee "$f" > /dev/null
    done
}

# AC Mode
laptop_mode_ac() {
    echo "[+] Applying AC settings..."
    set_power_profile balanced
    set_display_brightness 24720

    if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
        set_intel_pstate_param no_turbo 1
        set_intel_pstate_param max_perf_pct 100
        set_intel_pstate_param min_perf_pct 10
    elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
        set_cpu_governor ondemand
        set_scaling_freq max 2200000 
        set_scaling_freq min 600000 
    fi
}

# Battery Mode
laptop_mode_battery() {
    echo "[+] Applying Battery settings..."
    set_power_profile power-saver
    set_display_brightness 19968

    if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
        set_intel_pstate_param no_turbo 1
        set_intel_pstate_param max_perf_pct 50
        set_intel_pstate_param min_perf_pct 5
    elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
        set_cpu_governor conservative
        set_scaling_freq max 1200000
        set_scaling_freq min 600000
    fi
}

# Main switch
case "$ONLINE_STATUS" in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
esac

exit 0
