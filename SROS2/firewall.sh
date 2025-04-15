#!/bin/bash

source ./common.sh

ufw_setup() {
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow OpenSSH

    for ip in "${ROS_NODE_IPS[@]}"; do
        for port in {7400..7600}; do
            ufw allow from "$ip" to any port "$port" proto udp
        done
    done

    echo 'y' | ufw enable
}
