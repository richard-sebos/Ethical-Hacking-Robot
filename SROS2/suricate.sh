#!/bin/bash

source ./common.sh

suricata_setup() {
    apt install -y suricata
    echo 'alert udp any any -> any 7400:7600 (msg:"ROS2 DDS UDP Traffic Detected"; sid:100001;)' >> /etc/suricata/rules/local.rules
    echo 'include: local.rules' >> /etc/suricata/suricata.yaml
    systemctl enable --now suricata
}
