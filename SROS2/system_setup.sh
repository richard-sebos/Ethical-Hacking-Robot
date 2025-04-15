#!/bin/bash

source ./common.sh

timezone_and_update() {
    timedatectl set-timezone "$TIMEZONE"
    apt update
    apt full-upgrade -y
    apt install -y curl gnupg2 lsb-release software-properties-common ufw apparmor apparmor-utils auditd vim nano
}

create_ros_user() {
    id -u "$ROS_USER" &>/dev/null || (
        adduser --disabled-password --gecos '' "$ROS_USER"
        usermod -aG sudo "$ROS_USER"
    )
}
