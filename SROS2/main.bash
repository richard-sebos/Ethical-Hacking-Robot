#!/bin/bash

source ./common.sh
source ./system_setup.sh
source ./ros2_install.sh
source ./apparmor_audit.sh
source ./firewall.sh
source ./sros2_setup.sh
source ./suricata.sh
source ./security_report_setup.sh

touch "$STATE_FILE"

run_step "timezone_and_update" timezone_and_update
run_step "create_ros_user" create_ros_user
run_step "ros2_install" ros2_install
run_step "apparmor_and_audit" apparmor_and_audit
run_step "ufw_setup" ufw_setup
run_step "sros2_setup" sros2_setup
run_step "suricata_setup" suricata_setup
run_step "setup_security_report_timer" setup_security_report_timer

echo "[+] Fully Secured ROS2 install completed."

# Reset with: sudo rm -f /var/log/ros2_setup_state
