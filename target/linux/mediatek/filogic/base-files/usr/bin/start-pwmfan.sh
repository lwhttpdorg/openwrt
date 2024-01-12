#!/bin/bash

if [ ! -d /sys/class/pwm/pwmchip0 ]; then
    echo "this model does not support pwm."
    exit 1
fi

if [ ! -d /sys/class/pwm/pwmchip0/pwm0 ]; then
    echo -n 0 >/sys/class/pwm/pwmchip0/export
fi

sleep 1

while [ ! -d /sys/class/pwm/pwmchip0/pwm0 ]; do
    sleep 1
done

pwm_enabled=$(cat /sys/class/pwm/pwmchip0/pwm0/enable)
if [ ${pwm_enabled} -eq 1 ]; then
    echo -n 0 >/sys/class/pwm/pwmchip0/pwm0/enable
fi

wifi0_enabled=0
if [ -e /sys/class/ieee80211/phy0/hwmon1/temp1_input ]; then
    wifi0_enabled=1
fi

wifi1_enabled=0
if [ -e /sys/class/ieee80211/phy1/hwmon2/temp1_input ]; then
    wifi1_enabled=1
fi

echo -n 50000 >/sys/class/pwm/pwmchip0/pwm0/period
echo -n 1 >/sys/class/pwm/pwmchip0/pwm0/enable

# CPU
declare -a cpu_temp_set=(60000 55000 50000 45000 40000 35000 30000)
declare -a pwm_duty_set=(0 5000 10000 15000 20000 25000 30000)
declare -a wifi_temp_set=(70000 65000 60000 55000 50000 45000 40000)

cpu_pwm_duty=49999
wifi_pwm_duty=49999

pwm_duty=49999

while true; do
    wifi0_temp=0
    wifi1_temp=0
    cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)

    if [ ${wifi0_enabled} -eq 1 ]; then
        wifi0_temp=$(cat /sys/class/ieee80211/phy0/hwmon1/temp1_input)
    fi

    if [ ${wifi1_enabled} -eq 1 ]; then
        wifi1_temp=$(cat /sys/class/ieee80211/phy1/hwmon2/temp1_input)
    fi

    FOUND=0
    # CPU
    for ((i = 0; i < ${#cpu_temp_set[@]}; i++)); do
        if [ ${cpu_temp} -gt ${cpu_temp_set[$i]} ]; then
            cpu_pwm_duty=${pwm_duty_set[${i}]}
            FOUND=1
            break
        fi
    done

    # WiFi
    for ((i = 0; i < ${#wifi_temp_set[@]}; i++)); do
        if [[ ${wifi0_temp} -gt ${wifi_temp_set[$i]} || ${wifi1_temp} -gt ${wifi_temp_set[$i]} ]]; then
            wifi_pwm_duty=${pwm_duty_set[${i}]}
            FOUND=1
            break
        fi
    done

    if [ ${wifi_pwm_duty} -gt ${cpu_pwm_duty} ]; then
        pwm_duty=${cpu_pwm_duty}
    else
        pwm_duty=${wifi_pwm_duty}
    fi

    if [ ${FOUND} == 1 ]; then
        echo -n ${pwm_duty} >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
    fi
    sleep 3s
done

