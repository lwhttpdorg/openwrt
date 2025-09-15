#!/bin/bash

QMI_DEV=/dev/cdc-wdm0
QMI_LOG=/var/log/uqmi_daemon.log
MAX_FAILED_COUNT=10

# New logging function
function log() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [${level}]: ${message}" >> "${QMI_LOG}"
}

function set_device_operating_mode() {
    local dev=$1
    local mode=$2
    log "INFO" "Setting device ${dev} to mode '${mode}'."
    uqmi -d "${dev}" --set-device-operating-mode="${mode}"
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to set device operating mode for ${dev}."
    fi
}

function ping_domain() {
    local dnspod="119.29.29.29"
    local alidns="223.5.5.5"
    local retries=6
    local packets_responded=0

    for i in $(seq 1 $retries); do
        if ping -c 4 "${dnspod}" > /dev/null; then
            ((packets_responded++))
            sleep 3
        elif ping -c 4 "${alidns}" > /dev/null; then
            ((packets_responded++))
            sleep 3
        else
            log "WARN" "Ping failed on retry ${i}."
        fi
    done

    if [ "${packets_responded}" -ge 2 ]; then
        echo "true"
    else
        log "WARN" "Network check failed. Packets responded: ${packets_responded}."
        echo "false"
    fi
}

function ddns_ondemand() {
    # Check if service is started on boot
    log "INFO" "Checking DDNS status."
    /etc/init.d/ddns enabled
    if [ $? -eq 1 ]; then
        log "INFO" "DDNS autostart is disabled, nothing to do."
        return
    fi

    ps_ddns=$(ps | grep "dynamic_dns_upd" | grep -v "grep")
    if [ -z "${ps_ddns}" ]; then
        log "INFO" "DDNS is enabled but not running, starting now."
        /etc/init.d/ddns start
    else
        log "INFO" "DDNS is running, restarting now."
        /etc/init.d/ddns restart
    fi
}

#echo /dev/null > ${QMI_LOG}
log "INFO" "QMI daemon started."

FAILED_COUNT=0
NETWORK_STATUS="false"

while true; do
    if [ "$(ping_domain)" = "false" ]; then
        ((FAILED_COUNT++))
        if [ "${FAILED_COUNT}" -ge "${MAX_FAILED_COUNT}" ]; then
            log "FATAL" "Network cannot be restored after ${MAX_FAILED_COUNT} attempts. Rebooting the router."
            /sbin/reboot
        else
            log "WARN" "Network is unreachable. Attempting to reset the device (Attempt ${FAILED_COUNT} of ${MAX_FAILED_COUNT})."
            NETWORK_STATUS="false"
            set_device_operating_mode "${QMI_DEV}" reset
        fi
    else
        if [ "${NETWORK_STATUS}" = "false" ]; then
            NETWORK_STATUS="true"
            FAILED_COUNT=0
            log "INFO" "Network is now reachable."
            ddns_ondemand
        fi
    fi
    sleep 300
done

