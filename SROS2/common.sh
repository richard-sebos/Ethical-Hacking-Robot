#!/bin/bash

# Shared configuration and utility functions

ROS_DISTRO="jazzy"
ROS_USER="rosbot"
ROS_WS="/home/$ROS_USER/ros2_ws"
TIMEZONE="UTC"
STATE_FILE="/var/log/ros2_setup_state"
ROS_KEY_URL="https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc"
ROS_REPO_URL="http://packages.ros.org/ros2/ubuntu"
ROS_NODE_IPS=("192.168.1.10" "192.168.1.11")
# IP of laptop used for programming the robot
PROGRAMMER_LAPTOP_IP="192.168.1.100"  # <-- change to match your actual IP

log_step() { echo "$1" >> "$STATE_FILE"; }

has_run() { grep -q "$1" "$STATE_FILE" 2>/dev/null; }

abort_on_failure() { echo "[-] ERROR: $1"; exit 1; }

run_step() {
    local STEP_NAME="$1"
    shift
    if ! has_run "$STEP_NAME"; then
        echo "[*] Running: $STEP_NAME..."
        "$@" || abort_on_failure "$STEP_NAME failed"
        log_step "$STEP_NAME"
    else
        echo "[✓] Skipping: $STEP_NAME (already completed)"
    fi
}
