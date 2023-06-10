# Custom Linux Power Management Utilitites

## Description
This is Custom Power Management Utilities used to control power management in linux os. This scrpit mostly useful when using in laptop.

## Requirement
- Linux OS
- Latest Systemd
- Latest udev

## Installation
1. Create directory `/opt/pm-utils`.
```
sudo mkdir /opt/pm-utils && sudo chown $USER:root /opt/pm-utils && sudo chmod 755 /opt/pm-util
```
2. Copy file under `opt/pm-utils/` into `/opt/pm-utils/custom-mode.sh` directory in your system. **Choose only one which system you are have**:
- File with wording **ipstate** (`custom-mode-ipstate.sh`) used for system that have *intel pstate*.
```
cp ./opt/pm-utils/custom-mode-ipstate.sh /opt/pm-utils/custom-mode.sh
```
- File with wording **popos** (`custom-mode-popos.sh`) used for system running *Pop!_OS* and it use *System76* power management tool. 
```
cp ./opt/pm-utils/custom-mode-popos.sh /opt/pm-utils/custom-mode.sh
```
- File with wording **cpufreq** (`custom-mode-cpufreq.sh`) can be used for all kind of system including Pop!_OS, and system have *intel pstate*, it use the generic *cpufreq*.
```
cp ./opt/pm-utils/custom-mode-cpufreq.sh /opt/pm-utils/custom-mode.sh
```
- Make sure the script name is `custom-mode.sh`, and set the permission into executable.
```
sudo chmod 755 /opt/pm-utils/custom-mode.sh
```

### System using systemd and udev
1. Copy file under `usr/lib/systemd/system/pm-utils.service` into `/usr/lib/systemd/system/pm-utils.service` directory in your system.
```
sudo cp ./usr/lib/systemd/system/pm-utils.service /usr/lib/systemd/system/pm-utils.service
```

2. Copy file under `etc/udev/rules.d/99-pm-utils.service.rules` into `/etc/udev/rules.d/99-pm-utils.rules`.

```
sudo cp ./etc/udev/rules.d/99-pm-utils.service.rules /etc/udev/rules.d/99-pm-utils.rules
```

3. Run the following command in your terminal "`sudo systemctl daemon-reload`" and the run "`sudo udevadm control --reload`".
```
sudo cp ./etc/udev/rules.d/99-pm-utils.service.rules /etc/udev/rules.d/99-pm-utils.rules
```

### System not using systemd but have udev
1. Copy file under `etc/udev/rules.d/99-pm-utils.service.rules` into `/etc/udev/rules.d/99-pm-utils.rules`.
```
sudo cp ./etc/udev/rules.d/99-pm-utils.service.rules /etc/udev/rules.d/99-pm-utils.rules
```

2. Run the following command in your terminal "`sudo systemctl daemon-reload`" and the run "`sudo udevadm control --reload`".
```
sudo cp ./etc/udev/rules.d/99-pm-utils.service.rules /etc/udev/rules.d/99-pm-utils.rules
```

## License
Open LICENSE file.

## Project status
As long I life it should be active. Please don't hesistate to open the report if there any issue.
