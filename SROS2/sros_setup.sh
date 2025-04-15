#!/bin/bash

source ./common.sh

sros2_setup() {
    apt install -y openssl

    sudo -u "$ROS_USER" bash -c '
        source /opt/ros/$ROS_DISTRO/setup.bash
        mkdir -p $ROS_WS/sros2_keystore
        ros2 security create_keystore $ROS_WS/sros2_keystore
        ros2 security create_key $ROS_WS/sros2_keystore talker

        cat <<XML > $ROS_WS/sros2_keystore/permissions/talker.xml
<permissions>
  <grant name="talker_grant" subject_name="CN=talker">
    <validity>
      <not_before>2024-01-01T00:00:00</not_before>
      <not_after>2026-01-01T00:00:00</not_after>
    </validity>
    <allow rule="ALLOW">
      <domains>
        <id>0</id>
      </domains>
      <topics>
        <topic>*</topic>
      </topics>
      <partitions>
        <partition>*</partition>
      </partitions>
    </allow>
  </grant>
</permissions>
XML

        ros2 security create_permission $ROS_WS/sros2_keystore talker
    '
}
