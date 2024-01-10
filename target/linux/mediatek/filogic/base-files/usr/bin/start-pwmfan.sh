#!/bin/bash

if [ ! -d /sys/class/pwm/pwmchip0 ]; then
	echo "this model does not support pwm."
	exit 1
fi

if [ ! -d /sys/class/pwm/pwmchip0/pwm0 ]; then
	echo -n 0 > /sys/class/pwm/pwmchip0/export
fi

sleep 1

while [ ! -d /sys/class/pwm/pwmchip0/pwm0 ];
do
	sleep 1
done

pwm_enabled=`cat /sys/class/pwm/pwmchip0/pwm0/enable`
if [ $pwm_enabled -eq 1 ]; then
	echo -n 0 > /sys/class/pwm/pwmchip0/pwm0/enable
fi

echo -n 50000 > /sys/class/pwm/pwmchip0/pwm0/period
echo -n 1 > /sys/class/pwm/pwmchip0/pwm0/enable
echo normal > /sys/class/pwm/pwmchip0/pwm0/polarity

declare -a cpu_temp_set=(55000 45000 35000 25000)
declare -a pwm_duty_cycle_set=(10000 15000 25000 30000)

# default duty
duty=30000

while true
do
	temp=$(cat /sys/class/thermal/thermal_zone0/temp)
	INDEX=0
	FOUNDTEMP=0

	for i in 0 1 2 3; do
		if [ $temp -gt ${cpu_temp_set[$i]} ]; then
			INDEX=$i
			FOUNDTEMP=1
			break
		fi
	done
	if [ ${FOUNDTEMP} == 1 ]; then
		duty=${pwm_duty_cycle_set[$INDEX]}
		echo -n $duty > /sys/class/pwm/pwmchip0/pwm0/duty_cycle;
	fi
	sleep 2s;
done
