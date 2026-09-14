#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Asare Boateng Akuamoah
# @index        7353723
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates sample log data, then uses pipes and text tools
#               to summarize log levels, top IPs, and error lines.
# @date         2026-09-14
# -----------------------------------------------------------------

set -u

LOG_FILE="sample.log"
RESULTS_FILE="results.txt"
ERRORS_FILE="errors.log"

cat > "$LOG_FILE" << 'EOF'
2026-09-11 10:03:21 INFO 192.168.1.10 User login successful
2026-09-11 10:03:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:04:02 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:04:15 INFO 192.168.1.15 File uploaded successfully
2026-09-11 10:04:30 ERROR 192.168.1.23 Database connection failed
2026-09-11 10:04:50 INFO 192.168.1.10 User logout
2026-09-11 10:05:05 WARN 192.168.1.31 Memory usage above 75%
2026-09-11 10:05:20 INFO 192.168.1.15 User login successful
2026-09-11 10:05:40 ERROR 192.168.1.10 Authentication failed
2026-09-11 10:06:00 INFO 192.168.1.22 Page loaded successfully
2026-09-11 10:06:15 WARN 192.168.1.23 Disk usage above 85%
2026-09-11 10:06:30 INFO 192.168.1.15 User login successful
2026-09-11 10:06:45 ERROR 192.168.1.31 Connection timeout
2026-09-11 10:07:00 INFO 192.168.1.10 File downloaded successfully
2026-09-11 10:07:20 WARN 192.168.1.22 CPU usage above 90%
2026-09-11 10:07:35 INFO 192.168.1.23 User logout
2026-09-11 10:07:50 ERROR 192.168.1.15 Database connection failed
2026-09-11 10:08:05 INFO 192.168.1.10 User login successful
2026-09-11 10:08:20 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:08:40 INFO 192.168.1.22 File uploaded successfully
2026-09-11 10:08:55 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:09:10 INFO 192.168.1.15 User logout
2026-09-11 10:09:25 WARN 192.168.1.31 Memory usage above 80%
2026-09-11 10:09:40 INFO 192.168.1.10 Page loaded successfully
2026-09-11 10:09:55 ERROR 192.168.1.10 Authentication failed
2026-09-11 10:10:10 INFO 192.168.1.23 User login successful
2026-09-11 10:10:25 WARN 192.168.1.15 Disk usage above 85%
2026-09-11 10:10:40 INFO 192.168.1.22 File downloaded successfully
2026-09-11 10:10:55 ERROR 192.168.1.31 Connection timeout
2026-09-11 10:11:10 INFO 192.168.1.10 User logout
2026-09-11 10:11:25 WARN 192.168.1.23 CPU usage above 90%
2026-09-11 10:11:40 INFO 192.168.1.15 User login successful
2026-09-11 10:11:55 ERROR 192.168.1.10 Database connection failed
2026-09-11 10:12:10 INFO 192.168.1.22 Page loaded successfully
2026-09-11 10:12:25 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:12:40 INFO 192.168.1.23 File uploaded successfully
2026-09-11 10:12:55 ERROR 192.168.1.15 Connection timeout
2026-09-11 10:13:10 INFO 192.168.1.10 User login successful
2026-09-11 10:13:25 WARN 192.168.1.31 Memory usage above 85%
2026-09-11 10:13:40 INFO 192.168.1.22 User logout
2026-09-11 10:13:55 ERROR 192.168.1.23 Authentication failed
2026-09-11 10:14:10 INFO 192.168.1.15 File downloaded successfully
2026-09-11 10:14:25 WARN 192.168.1.10 Disk usage above 90%
2026-09-11 10:14:40 INFO 192.168.1.10 User login successful
2026-09-11 10:14:55 ERROR 192.168.1.31 Connection timeout
2026-09-11 10:15:10 INFO 192.168.1.23 Page loaded successfully
2026-09-11 10:15:25 WARN 192.168.1.15 CPU usage above 90%
2026-09-11 10:15:40 INFO 192.168.1.22 User login successful
2026-09-11 10:15:55 ERROR 192.168.1.10 Database connection failed
2026-09-11 10:16:10 INFO 192.168.1.10 User logout
2026-09-11 10:16:25 WARN 192.168.1.23 Disk usage above 80%
EOF

if [[ $? -eq 0 ]]; then
  echo "Success: generated sample log data in '$LOG_FILE' ($(wc -l < "$LOG_FILE") lines)."
else
  echo "Error: failed to generate log data." >&2
  exit 1
fi
{
  echo "Log Analysis Report"
  echo "===================="
  echo ""

  echo "Total log lines:"
  wc -l < "$LOG_FILE"
  echo ""

  echo "Lines per log level:"
  awk '{print $3}' "$LOG_FILE" | sort | uniq -c | sort -rn
  echo ""

  echo "Top 3 most frequent IP addresses:"
  awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -3
  echo ""

  echo "All ERROR lines:"
  grep "ERROR" "$LOG_FILE"

} > "$RESULTS_FILE" 2> "$ERRORS_FILE"

if [[ $? -eq 0 ]]; then
  echo "Success: report written to '$RESULTS_FILE'."
else
  echo "Error: something went wrong generating the report - check '$ERRORS_FILE'." >&2
  exit 1
fi
