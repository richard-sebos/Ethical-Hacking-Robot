#!/bin/bash

source ./common.sh

ros2_install() {
    apt update
    apt install -y curl gnupg2 lsb-release software-properties-common
    curl -sSL "$ROS_KEY_URL" -o /etc/apt/trusted.gpg.d/ros.asc
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/ros.asc] $ROS_REPO_URL $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2.list
    apt update
    apt install -y ros-$ROS_DISTRO-ros-base python3-rosdep python3-colcon-common-extensions python3-argcomplete colcon

    [ -f /etc/ros/rosdep/sources.list.d/20-default.list ] || rosdep init
    rosdep update

    grep -q "source /opt/ros/$ROS_DISTRO/setup.bash" /home/$ROS_USER/.bashrc || echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$ROS_USER/.bashrc
}
