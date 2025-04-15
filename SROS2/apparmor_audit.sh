#!/bin/bash

source ./common.sh

apparmor_and_audit() {
    systemctl enable apparmor
    systemctl start apparmor

    mkdir -p /etc/apparmor.d/ros2/
    echo "# Placeholder ROS2 AppArmor profile" > /etc/apparmor.d/ros2/ros2-default

    cat <<EOF > /etc/audit/rules.d/ros2.rules
-w /opt/ros -p x -k ros_exec
-w /home/$ROS_USER/ros2_ws -p x -k ros_ws_exec
-w /home/$ROS_USER/ros2_ws/src -p wa -k ros_src
-w /etc/ros2 -p wa -k ros_conf
-w /usr/bin/colcon -p x -k colcon_exec
-w /usr/bin/rosdep -p x -k rosdep_exec
-w /home/$ROS_USER/.bashrc -p wa -k ros_env
EOF

    augenrules --load
    systemctl enable auditd
    systemctl start auditd
}
