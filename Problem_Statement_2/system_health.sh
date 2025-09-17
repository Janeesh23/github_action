#!/bin/bash

CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80
PROC_THRESHOLD=300    


LOG_FILE="/var/log/sys_health.log"


touch "$LOG_FILE" 2>/dev/null || {
    echo "ERROR: Cannot write to $LOG_FILE. Check permissions."
    exit 1
}

log_alert() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $1" >> "$LOG_FILE"
}


cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
cpu_usage=${cpu_usage%.*}
if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
    log_alert "ALERT: CPU usage high at ${cpu_usage}%"
fi


mem_usage=$(free | awk '/Mem/{printf("%.0f"), $3/$2 * 100}')
if [ "$mem_usage" -gt "$MEM_THRESHOLD" ]; then
    log_alert "ALERT: Memory usage high at ${mem_usage}%"
fi


while read -r line; do
    usage=$(echo "$line" | awk '{print $1}' | tr -d '%')
    mount_point=$(echo "$line" | awk '{print $2}')
    if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
        log_alert "ALERT: Disk usage high on $mount_point at ${usage}%"
    fi
done < <(df -h --output=pcent,target | tail -n +2)


proc_count=$(ps -e --no-headers | wc -l)
if [ "$proc_count" -gt "$PROC_THRESHOLD" ]; then
    log_alert "ALERT: High number of processes running: $proc_count"
fi

exit 0
