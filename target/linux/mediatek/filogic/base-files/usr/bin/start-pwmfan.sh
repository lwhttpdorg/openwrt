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
if [ $pwm_enabled -eq 1 ]; then
    echo -n 0 >/sys/class/pwm/pwmchip0/pwm0/enable
fi

echo -n 50000 >/sys/class/pwm/pwmchip0/pwm0/period
echo -n 1 >/sys/class/pwm/pwmchip0/pwm0/enable

declare -a cpu_temp_set=(55000 50000 45000 40000 35000 30000 25000)
declare -a pwm_duty_cycle_set=(0 1000 5000 10000 15000 20000 25000)

# default duty
duty=49999

while true; do
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    INDEX=0
    FOUND=0

    for ((i = 0; i < ${#cpu_temp_set[@]}; i++)); do
        if [ $temp -gt ${cpu_temp_set[$i]} ]; then
            INDEX=$i
            FOUND=1
            break
        fi
    done
    if [ ${FOUND} == 1 ]; then
        duty=${pwm_duty_cycle_set[${INDEX}]}
        echo -n $duty >/sys/class/pwm/pwmchip0/pwm0/duty_cycle
    fi
    sleep 2s
done

