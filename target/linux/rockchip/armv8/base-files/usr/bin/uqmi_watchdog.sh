#!/bin/bash

# Configuration
QMI_DEV="/dev/cdc-wdm0"
LOG_FILE="/var/log/uqmi_watchdog.log"
MAX_FAILED_COUNT=10
CHECK_INTERVAL=300 # 5 minutes

# Logging function
function log() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [${level}]: ${message}" >> "${LOG_FILE}"
}

# Generic service watchdog function
# Param 1: service_name (for init.d)
# Param 2: process_name (for ps grep)
function check_and_recover_service() {
    local svc=$1
    local proc=$2

    # Only attempt recovery if the service is explicitly enabled
    # 0 means enabled in OpenWrt
    /etc/init.d/"${svc}" enabled
    if [ $? -ne 0 ]; then
        log "INFO" "service '${svc}' is disabled. skip..."
        return
    fi

    # Check if the process is actually running
    if ps | grep -v "grep" | grep "${proc}"; then
        log "INFO" "service '${svc}' (${proc}) is running. do nothing."
    else
        log "WARN" "service '${svc}' (${proc}) is not running. start it..."
        /etc/init.d/"${svc}" restart
        if [ $? -ne 0 ]; then
            log "ERROR" "failed to restart service '${svc}' (${proc})."
        fi
    fi
}

# Network connectivity check
function check_connectivity() {
    local dnspod="119.29.29.29"
    local alidns="223.5.5.5"
    local max_retries=6
    local reachable=0

    for i in $(seq 1 "${max_retries}"); do
        # Priority: try DNSPod first, then AliDNS.
        if ping -c 4 -W 3 "${dnspod}" > /dev/null 2>&1; then
            reachable=1
            break
        elif ping -c 4 -W 3 "${alidns}" > /dev/null 2>&1; then
            reachable=1
            break
        else
            log "WARN" "Ping failed on retry ${i}."
            sleep 3
        fi
    done

    if [ "${reachable}" -eq 1 ]; then
        return 0
    fi
    return 1
}

# Tasks to execute after network becomes reachable.
function post_network_recovery() {
    log "INFO" "network is reachable. run post-network recovery tasks."
    check_and_recover_service "ddns" "dynamic_dns"
    check_and_recover_service "frpc" "frpc"
}

# Set modem operating mode via uqmi
function set_device_operating_mode() {
    local dev=$1
    local mode=$2
    log "INFO" "setting device ${dev} to mode '${mode}'."
    timeout 5 uqmi -d "${dev}" --set-device-operating-mode="${mode}"
    if [ $? -ne 0 ]; then
        log "ERROR" "failed to set operating mode for ${dev}."
    fi
}

log "INFO" "QMI watchdog is running..."

FAILED_COUNT=0
NETWORK_STATUS=0

while true; do
    if ! check_connectivity; then
        ((FAILED_COUNT++))
        if [ "${FAILED_COUNT}" -ge "${MAX_FAILED_COUNT}" ]; then
            log "FATAL" "network down after ${MAX_FAILED_COUNT} retries. reboot system."
            /sbin/reboot
        else
            NETWORK_STATUS=0
            set_device_operating_mode "${QMI_DEV}" reset
            sleep 30
        fi
    else
        # network is reachable
        if [ $NETWORK_STATUS -eq 0 ]; then
            NETWORK_STATUS=1
            FAILED_COUNT=0
            post_network_recovery
        fi
        sleep "${CHECK_INTERVAL}"
    fi
done

