#!/bin/sh

ONLINE_STATUS=$(cat /sys/class/power_supply/AC/online)

#cat /sys/class/backlight/acpi_video0/brightness
#4 to 15
set_display_brightness_acpi() {
        echo $1 | sudo tee /sys/class/backlight/intel_backlight/brightness
}

#cat /sys/devices/system/cpu/intel_pstate/no_turbo
#1 or 0
set_cpu_noturbo() {
        echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
}

#cat /sys/devices/system/cpu/intel_pstate/max_perf_pct
#5 to 100
set_cpu_max_perf_pct() {
        echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
}

#cat /sys/devices/system/cpu/intel_pstate/min_perf_pct
#5 to 100
set_cpu_min_perf_pct() {
        echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/min_perf_pct
}

#/usr/bin/powerprofilesctl list
#performance, balanced, power-saver
set_power_profile() {
        /usr/bin/powerprofilesctl set $1
}

# Edit to meet your disire config
laptop_mode_ac() {
        sleep 1
        set_power_profile balanced
        set_cpu_noturbo 1
        set_cpu_max_perf_pct 100
        set_cpu_min_perf_pct 10
        set_display_brightness_acpi 24720
}

# Edit to meet your disire config
laptop_mode_battery() {
        sleep 1
        set_power_profile power-saver
        set_cpu_noturbo 1
        set_cpu_max_perf_pct 50
        set_cpu_min+perf_pct 5
        set_display_brightness_acpi 19968
}


case $ONLINE_STATUS in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
esac

exit 0