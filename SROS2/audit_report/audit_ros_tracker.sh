#!/bin/bash
################################################################################
# ROS Auditd Event Logger
#
# Description:
#   This script collects audit events related to ROS activities (e.g., colcon, 
#   rosdep, workspace changes), formats them as CSV, deduplicates entries, and 
#   appends new events to a log file. 
#
# Output:
#   - CSV log file located at /var/log/audit_ros_events.csv
#
# Author: <Your Name>
# Date: <Date>
################################################################################

# -------------------------------
# 🛠️ Configuration Section
# -------------------------------

# Define audit keys associated with specific monitored events
AUDIT_KEYS=("colcon_exec" "rosdep_exec" "ros_exec" "ros_ws_exec" "ros_src" "ros_conf" "ros_env")

# Path to the persistent CSV log file
LOG_FILE="/var/log/audit_ros_events.csv"

# Temporary file for holding new log entries before deduplication
TMP_FILE=$(mktemp)

# -------------------------------
# 📄 Initialize CSV Header if Not Present
# -------------------------------
if [ ! -f "$LOG_FILE" ]; then
    echo "Time,User,Command,Auditd" > "$LOG_FILE"
fi

# -------------------------------
# 🔍 Process Audit Events by Key
# -------------------------------
for KEY in "${AUDIT_KEYS[@]}"; do
    ausearch -k "$KEY" | awk -v audit_key="$KEY" '
    # Extract timestamp and user information from SYSCALL events
    /^type=SYSCALL/ {
        if (match($0, /audit\(([0-9]+)\./, ts)) {
            event_time = strftime("%Y-%m-%d %H:%M:%S", ts[1])
        } else {
            event_time = "unknown"
        }
        user_id = "unknown"
        if (match($0, /auid=([^ ]+)/, au) && au[1] != "4294967295") {
            user_id = au[1]
        } else if (match($0, /uid=([^ ]+)/, uid)) {
            user_id = uid[1]
        }
    }

    # Extract executed command details from EXECVE events
    /^type=EXECVE/ {
        cmd = ""
        for (i = 1; i <= NF; i++) {
            if ($i ~ /^a[0-9]=/) {
                split($i, kv, "=")
                gsub(/^"|"$/, "", kv[2])  # Remove any surrounding quotes
                cmd = cmd " \"" kv[2] "\""
            }
        }

        # Resolve UID to username for better readability
        if (user_id != "unknown") {
            cmd_getuser = "getent passwd " user_id " | cut -d: -f1"
            cmd_getuser | getline username
            close(cmd_getuser)
            if (username != "") {
                user_display = username
            } else {
                user_display = "UID " user_id
            }
        } else {
            user_display = "unset"
        }

        # Output as CSV format: "Time","User","Command",AuditKey
        printf("\"%s\",\"%s\",\"%s\",%s\n", event_time, user_display, cmd, audit_key)
    }' >> "$TMP_FILE"
done

# -------------------------------
# 📑 Deduplicate and Append New Entries to Log
# -------------------------------
grep -Fvx -f "$LOG_FILE" "$TMP_FILE" >> "$LOG_FILE"

# -------------------------------
# 🧹 Cleanup Temporary Files
# -------------------------------
rm -f "$TMP_FILE"

# 📢 Final Status Message
echo "✅ Audit log updated successfully at: $LOG_FILE"
