#!/bin/bash

IF_WAN_LOG=/var/log/if_wan.log
MAX_FAILED_COUNT=10

function restart_if_wan() {
    ifdown wan
	sleep 1
	ifup wan
}

function ping_domain() {
    local dnspod=119.29.29.29
    local alidns=223.5.5.5
    local retries=6
    local packets_responded=0

    for i in $(seq 1 $retries); do
        if ping -c 4 ${dnspod} > /dev/null; then
            ((packets_responded++))
            sleep 3
        elif ping -c 4 ${alidns} > /dev/null; then
            ((packets_responded++))
            sleep 3
        fi
    done

    if [ ${packets_responded} -ge 2 ]; then
        echo "true"
    else
        echo "false"
    fi
}

#echo /dev/null > ${IF_WAN_LOG}
echo "$(date '+%Y-%m-%d %H:%M:%S'): WAN interface monitor is running..." >> ${IF_WAN_LOG}

FAILED_COUNT=0
NETWORK_STATUS=false

while true; do
    if [ $(ping_domain) = "false" ]; then
        ((FAILED_COUNT+=1))
        if [ ${FAILED_COUNT} -ge ${MAX_FAILED_COUNT} ]; then
            # reboot
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Network cannot be restored! restart the router..." >> ${IF_WAN_LOG}
            /sbin/reboot
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Network is unreachable, try to reset" >> ${IF_WAN_LOG}
	NETWORK_STATUS=false
        restart_if_wan
        sleep 30
    else
        if [ ${NETWORK_STATUS} = "false" ]; then
            NETWORK_STATUS=true
            FAILED_COUNT=0
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Network is reachable" >> ${IF_WAN_LOG}
        fi
    fi
    sleep 300
done

