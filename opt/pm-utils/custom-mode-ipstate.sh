#!/bin/sh

ONLINE_STATUS=$(cat /sys/class/power_supply/AC/online)

#cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
#powersave performance
set_cpu_governor() {
	for CPUGOVERNOR in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
        do
                [ -f $CPUGOVERNOR ] || continue
                echo $1 | sudo tee $CPUGOVERNOR
        done
}

#cat /sys/devices/system/cpu/intel_pstate/max_perf_pct
#5 to 100
set_cpu_maxpct() {
	echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
}

#cat /sys/devices/system/cpu/intel_pstate/min_perf_pct
#5 to 100
set_cpu_minpct() {
	echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/min_perf_pct
}

#cat /sys/devices/system/cpu/intel_pstate/no_turbo
#1 or 0
set_cpu_noturbo() {
	echo $1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
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

#cat /sys/class/backlight/acpi_video0/brightness
#4 to 15
set_display_brightness_acpi() {
	#sleep 3
	echo $1 | sudo tee /sys/class/backlight/acpi_video0/brightness
}

send_osd_notification()
{
	sudo -u trifupay DISPLAY=:0.0 notify-send "Power Management" "Power mode changed to $1"
}

# Edit to meet your disire config
laptop_mode_ac() {
	set_cpu_governor powersave
	set_cpu_maxpct 100
	set_cpu_minpct 26
	set_cpu_noturbo 0
	set_hdparm_apm 127
	set_hdparm_idletime 241
	set_display_brightness_acpi 11
	#send_osd_notification AC
}

# Edit to meet your disire config
laptop_mode_battery() {
	set_cpu_governor powersave
	set_cpu_maxpct 50
	set_cpu_minpct 26
	set_cpu_noturbo 1
	set_hdparm_apm 127
	set_hdparm_idletime 120
	set_display_brightness_acpi 7
	#send_osd_notification Battery
}

case $ONLINE_STATUS in
    0) laptop_mode_battery ;;
    1) laptop_mode_ac ;;
esac

exit 0