#!/bin/bash

JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="s3://janeesh-jenkins-logs"
REPORT_BUCKET="s3://janeesh-jenkins-backup-reports"
DATE=$(date +%Y-%m-%d)
REPORT_FILE="/tmp/jenkins_backup_report_$DATE.log"


total=0
success=0
failure=0


if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it to proceed."
    exit 1
fi

echo "Backup Report - $DATE" > "$REPORT_FILE"
echo "-----------------------------------" >> "$REPORT_FILE"


for job_dir in "$JENKINS_HOME/jobs/"*/; do
    job_name=$(basename "$job_dir")
    
    for build_dir in "$job_dir/builds/"*/; do
        build_number=$(basename "$build_dir")
        log_file="$build_dir/log"
        
        if [ -f "$log_file" ] && [ "$(date -r "$log_file" +%Y-%m-%d)" == "$DATE" ]; then
            ((total++))
            
            aws s3 cp "$log_file" "$S3_BUCKET/$job_name-$build_number.log" --only-show-errors
            if [ $? -eq 0 ]; then
                echo "[SUCCESS] Uploaded $job_name/$build_number" | tee -a "$REPORT_FILE"
                ((success++))
                
                rm -f "$log_file"
                echo "Deleted local log: $log_file" >> "$REPORT_FILE"
            else
                echo "[FAILURE] Failed to upload $job_name/$build_number" | tee -a "$REPORT_FILE"
                ((failure++))
            fi
        fi
    done
done


echo "-----------------------------------" >> "$REPORT_FILE"
echo "Total Files Processed: $total" >> "$REPORT_FILE"
echo "Successful Uploads   : $success" >> "$REPORT_FILE"
echo "Failed Uploads       : $failure" >> "$REPORT_FILE"


aws s3 cp "$REPORT_FILE" "$REPORT_BUCKET/jenkins_backup_report_$DATE.log" --only-show-errors

if [ $? -eq 0 ]; then
    echo "Backup report uploaded successfully to $REPORT_BUCKET/jenkins_backup_report_$DATE.log"
else
    echo "Failed to upload backup report to $REPORT_BUCKET"
fi


