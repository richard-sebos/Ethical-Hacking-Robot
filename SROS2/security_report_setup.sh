#!/bin/bash

source ./common.sh

setup_security_report_timer() {
  # Ensure script is in the right place
  cp ./ros2_security_report.sh /usr/local/bin/ros2_security_report.sh
  chmod 700 /usr/local/bin/ros2_security_report.sh

  # Move and secure service and timer
  cp ./ros2-security-report.service /etc/systemd/system/ros2-security-report.service
  cp ./ros2-security-report.timer /etc/systemd/system/ros2-security-report.timer

  chmod 644 /etc/systemd/system/ros2-security-report.*

  # Reload and enable
  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable --now ros2-security-report.timer

  echo "[+] ROS2 Security Report Timer Setup Complete."
}
