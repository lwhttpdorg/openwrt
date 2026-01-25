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
# Param 3: force_restart (true/false)
function check_and_recover_service() {
    local svc=$1
    local proc=$2
    local force=$3

    # Only attempt recovery if the service is explicitly enabled
    # 0 means enabled in OpenWrt
    /etc/init.d/"${svc}" enabled
    if [ $? -ne 0 ]; then
        log "INFO" "Service '${svc}' is disabled, nothing to do."
        return
    fi

    if [ "$force" = "true" ]; then
        log "WARN" "Service '${svc}' requires force restart. Restarting..."
        /etc/init.d/"${svc}" restart
    return
    fi
    # Check if the process is actually running
    if ps | grep -v "grep" | grep "${proc}"; then
        log "INFO" "Service '${svc}' (${proc}) is already running."
    else
        log "WARN" "Service '${svc}' (${proc}) is not running. Starting..."
        /etc/init.d/"${svc}" restart
    fi
}

# Set modem operating mode via uqmi
function set_device_operating_mode() {
    local dev=$1
    local mode=$2
    log "INFO" "Setting device ${dev} to mode '${mode}'."
    uqmi -d "${dev}" --set-device-operating-mode="${mode}"
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to set operating mode for ${dev}."
    fi
}

# Network connectivity check
function check_connectivity() {
    local dnspod="119.29.29.29"
    local alidns="223.5.5.5"
    local retries=6
    local packets_responded=0

    for i in $(seq 1 $retries); do
        if ping -c 4 -W 3 "${dnspod}" > /dev/null 2>&1; then
            ((packets_responded++))
            sleep 3
        elif ping -c 4 -W 3 "${alidns}" > /dev/null 2>&1; then
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

# Tasks to execute immediately after network restoration
function on_network_recovery() {
    log "INFO" "Network recovery detected. Running post-recovery tasks."

    check_and_recover_service "ddns" "dynamic_dns" "true"

    check_and_recover_service "frpc" "frpc" "false"
}

log "INFO" "QMI watchdog started."

FAILED_COUNT=0
NETWORK_UP="false"

while true; do
    if [ "$(check_connectivity)" = "false" ]; then
        ((FAILED_COUNT++))
        if [ "${FAILED_COUNT}" -ge "${MAX_FAILED_COUNT}" ]; then
            log "FATAL" "Network dead after ${MAX_FAILED_COUNT} retries. Rebooting system."
            /sbin/reboot
        else
            log "WARN" "Network down. Resetting ${QMI_DEV} (Attempt ${FAILED_COUNT}/${MAX_FAILED_COUNT})."
            NETWORK_UP="false"
            set_device_operating_mode "${QMI_DEV}" reset
        fi
    else
        # Network is healthy
        if [ "${NETWORK_UP}" = "false" ]; then
            NETWORK_UP="true"
            FAILED_COUNT=0
            log "INFO" "Network is now reachable."
            on_network_recovery
        fi
    fi

    sleep "${CHECK_INTERVAL}"
done

