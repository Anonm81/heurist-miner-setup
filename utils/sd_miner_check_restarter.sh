#!/bin/bash
log_folder="miner-release"
setup_script="setup.sh"
cooldown_minutes=5
term_width=$(tput cols)
term_height=$(tput lines)
restart_log_file="./restart_log.csv"  # Define the path to the log file for restart records
debug_log_file="./debug_log.txt"      # Define the path for detailed debug logs
setup_log_file="./setup_log.txt"

# Ensure the log files exist and if not, create them with headers
if [ ! -f "$restart_log_file" ]; then
    echo "Restart Triggered Time,Last Request Timestamp" > "$restart_log_file"
fi

if [ ! -f "$debug_log_file" ]; then
    echo "Debug logs for sd_checker.sh" > "$debug_log_file"
fi

# Adding a function to handle unexpected exits and log them
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Script exited unexpectedly." >> "$debug_log_file"
}
trap cleanup EXIT

# Main loop
while true; do
    restart_setup=false
    for log_file in "$log_folder"/sd-miner*log; do
        if [ -f "$log_file" ]; then
            last_line=$(grep -a "Request ID.*completed.*Total time.*" "$log_file" | tail -1)

            timestamp=""
            elapsed_time=""

            if [ -n "$last_line" ]; then
                timestamp=$(echo "$last_line" | awk '{print $1 " " $2}')
                current_time=$(date +%s)
                last_request_time=$(date -d "$timestamp" +%s)
                elapsed_time=$((current_time - last_request_time))

                # Log the comparison detail
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking log file: $log_file. Last request time: $timestamp, Elapsed Time: $elapsed_time seconds" >> "$debug_log_file"

                if [ $elapsed_time -gt 600 ]; then
                    echo "Log file $log_file has not processed any requests within the last 10 minutes."
                    restart_setup=true
                fi
            else
                echo "Log file $log_file has not processed any requests."
                restart_setup=true
            fi
        fi
    done

    if $restart_setup; then
        current_formatted_time=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$current_formatted_time,$timestamp" >> "$restart_log_file"
        echo "At least one log file has not processed any requests within the last 10 minutes. Restarting setup.sh..."
        #echo "1" | script -qc "stty rows $term_height cols $term_width; sh $setup_script &> $setup_log_file &" /dev/null
        
        nohup sh -c "echo 1 | script -qc 'stty rows $term_height cols $term_width; sh $setup_script' /dev/null" > "$setup_log_file" 2>&1 &

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Restart triggered due to no requests. Last request was at $timestamp" >> "$debug_log_file"
        echo "Waiting for $cooldown_minutes minutes before checking logs again."
        sleep $((cooldown_minutes * 60))
    else
        echo "All log files have processed requests within the last 10 minutes. Waiting..."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - No restart needed. Last Request processed at $elapsed_time seconds ago." >> "$debug_log_file"
        sleep 60  # Wait for 60 seconds before checking again
    fi
done
