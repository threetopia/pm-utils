#!/bin/sh

# Get power status: 1 = on AC, 0 = on battery
ONLINE_STATUS=$(cat /sys/class/power_supply/ADP1/online 2>/dev/null)

#cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
#powersave performance
set_cpu_governor() {
	for CPUGOVERNOR in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        do
                [ -f $CPUGOVERNOR ] || continue
                echo $1 | sudo tee $CPUGOVERNOR
        done
}

#cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
#2201000 2200000 2100000 2000000 1800000 1700000 1600000 1500000 1300000 1200000 1100000 1000000 900000 700000 600000 500000
set_scaling_max_freq() {
	for CPUMAXFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
        do
                [ -f $CPUMAXFREQ ] || continue
                echo $1 | sudo tee $CPUMAXFREQ
        done
}

#cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
#2201000 2200000 2100000 2000000 1800000 1700000 1600000 1500000 1300000 1200000 1100000 1000000 900000 700000 600000 500000
set_scaling_min_freq() {
	for CPUMINFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
        do
                [ -f $CPUMINFREQ ] || continue
                echo $1 | sudo tee $CPUMINFREQ
        done
}

#cat /sys/devices/system/cpu/cpufreq/boost
set_boost() {
	echo $1 | sudo tee /sys/devices/system/cpu/cpufreq/boost
}

#hdparm -B /dev/sda
#1 to 127 allow, 128 to 254 not allow, 255 disabled
set_hdparm_apm()
{
	hdparm -B $1 /dev/sda	
}

#hdparam -I /dev/sda
#1 to 240 * 5sec, 241 to 251 * 30min
set_hdparm_idletime()
{
	hdparm -S $1 /dev/sda	
}

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

send_osd_notification()
{
	sudo -u trifupay DISPLAY=:0.0 notify-send "Power Management" "Power mode changed to $1"
}

# Edit to meet your disire config
laptop_mode_ac() {
	set_cpu_governor ondemand
	set_scaling_max_freq 2201000
	set_scaling_min_freq 500000
	set_boost 1
	set_hdparm_apm 127
	set_hdparm_idletime 241
	set_display_brightness 11
	#send_osd_notification AC
}

# Edit to meet your disire config
laptop_mode_battery() {
	set_cpu_governor conservative
	set_scaling_max_freq 1200000
	set_scaling_min_freq 500000
	set_boost 0
	set_hdparm_apm 127
	set_hdparm_idletime 120
	set_display_brightness 7
	#send_osd_notification Battery
}

case $ONLINE_STATUS in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
esac

exit 0