#!/bin/bash

set -e  # Exit on any error

# Load configuration variables
source setup_config.sh

LOGFILE="/home/$USERNAME/setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    echo "✅ User $USERNAME already exists. Exiting setup."
    exit 0
fi

# Create user
sudo adduser --disabled-password --gecos "" $USERNAME

echo "🔹 Creating directory structure for ROS2 workspace and GitHub..."

# Create ROS2 workspace directories
sudo -u $USERNAME mkdir -p $USER_HOME/ros2_ws/src/{robot_control,sensor_interface,network_scanner,shared_interfaces}

# Create standalone non-ROS2 code directories
sudo -u $USERNAME mkdir -p $USER_HOME/non_ros_code/{ai_module,vision_lib,network_utils}

# Create database directories
sudo -u $USERNAME mkdir -p $USER_HOME/database/migrations
sudo -u $USERNAME touch $USER_HOME/database/scans.db

# Create robot file storage directories
sudo -u $USERNAME mkdir -p $USER_HOME/robot_files/{logs,reports,temp}


# Create multi-device build directories
sudo -u $USERNAME mkdir -p $USER_HOME/build/{jetson_nano,jetson_orin,orange_pi}

# Create GitHub repository structure
#sudo -u $USERNAME mkdir -p $USER_HOME/github/{dev,stage,prod}
#sudo -u $USERNAME mkdir -p $USER_HOME/github/dev/src
#sudo -u $USERNAME mkdir -p $USER_HOME/github/stage/src
#sudo -u $USERNAME mkdir -p $USER_HOME/github/prod/src


# Create ROS2 install and log directories
sudo -u $USERNAME mkdir -p $USER_HOME/install
sudo -u $USERNAME mkdir -p $USER_HOME/log
sudo -u $USERNAME touch $USER_HOME/colcon.meta

# Create environment setup script
sudo -u $USERNAME touch $USER_HOME/setup.sh

echo "✅ Directory structure created."

# Call GitHub setup script
bash setup_github.sh "$USERNAME" "$GITHUB_REPO" "$GIT_USER_NAME" "$GIT_USER_EMAIL" "$GITHUB_API_TOKEN"

# Set ownership
sudo chown -R $USERNAME:$USERNAME $USER_HOME

echo "✅ Setup complete! Now log in as $USERNAME and continue development."
echo "👉 Run: 'su - $USERNAME'"
