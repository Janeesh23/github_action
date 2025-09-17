#!/bin/bash

# ========================
# System Health Monitoring
# ========================

# Configurable thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80
PROC_THRESHOLD=300    # alert if running processes exceed this

# Log file (change path if needed)
LOG_FILE="/var/log/sys_health.log"

# Ensure log file is writable
touch "$LOG_FILE" 2>/dev/null || {
    echo "ERROR: Cannot write to $LOG_FILE. Check permissions."
    exit 1
}

log_alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" >> "$LOG_FILE"
}

# 1. CPU Usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
cpu_usage=${cpu_usage%.*}
if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
    log_alert "ALERT: CPU usage high at ${cpu_usage}%"
fi

# 2. Memory Usage
mem_usage=$(free | awk '/Mem/{printf("%.0f"), $3/$2 * 100}')
if [ "$mem_usage" -gt "$MEM_THRESHOLD" ]; then
    log_alert "ALERT: Memory usage high at ${mem_usage}%"
fi

# 3. Disk Usage (check all mounted filesystems)
while read -r line; do
    usage=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount_point=$(echo "$line" | awk '{print $6}')
    if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
        log_alert "ALERT: Disk usage high on $mount_point at ${usage}%"
    fi
done < <(df -h --output=pcent,target | tail -n +2)

# 4. Process Count
proc_count=$(ps -e --no-headers | wc -l)
if [ "$proc_count" -gt "$PROC_THRESHOLD" ]; then
    log_alert "ALERT: High number of processes running: $proc_count"
fi

exit 0
