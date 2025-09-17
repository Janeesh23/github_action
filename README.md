1. [Kubernetes Manifests inlcuding the KubeArmor policy](./kubernetes/)
2. [Problem Statement-2](./Problem_Statement_2/)
-  [Automated Backup Solution](./Problem_Statement_2/jenkins_backup.sh)
    This Bash script automates the backup of Jenkins job build logs to Amazon S3. It:
    Scans all Jenkins jobs and their build directories.
    Uploads logs from the current date to a specified S3 bucket.
    Removes successfully uploaded logs from local storage.
    Generates a detailed backup report (success/failure counts).
    Uploads the report itself to a separate S3 bucket for tracking.

-  [ System Health Monitoring Script](./Problem_Statement_2/system_health.sh)
    This Bash script continuously monitors critical Linux system metrics and logs alerts to /var/log/sys_health.log when thresholds are exceeded. It checks:
    CPU usage (via top)
    Memory usage (via free)
    Disk usage (via df)
    Process count (via ps)
    It generates alerts only when thresholds are breached to keep logs clean and actionable.
