#!/bin/bash

REPORT_DIR="/var/log/ros2_security"
REPORT_FILE="$REPORT_DIR/security_report_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$REPORT_DIR"

{
  echo "[ROS2 Security Report] $(date)"
  echo "=========================================="

  echo "\n[UFW Status]"
  ufw status numbered

  echo -e "\n[Recent UFW Logs]"
  grep 'UFW ' /var/log/syslog | tail -n 10 || echo "No recent UFW logs."

  echo -e "\n[Suricata Alerts]"
  tail -n 20 /var/log/suricata/fast.log 2>/dev/null || echo "No Suricata logs found."

  echo -e "\n[Recent Auditd Events]"
  ausearch -ts recent -k ros_exec -k ros_ws_exec -k ros_src -k ros_conf -k rosdep_exec -k ros_env 2>/dev/null | tail -n 20 || echo "No auditd events found."

  echo -e "\n[AppArmor Denials]"
  dmesg | grep -i apparmor | tail -n 10 || echo "No AppArmor denials found."
} > "$REPORT_FILE"

chmod 600 "$REPORT_FILE"
echo "[+] Report saved to: $REPORT_FILE"
