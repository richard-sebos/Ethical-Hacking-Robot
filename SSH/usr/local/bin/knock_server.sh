#!/bin/bash
# =========================================================
# Filename: knock_server.sh
# Company: Sebos Technology
# Date: 2025-02-08
# Author: Sebos Technology Team
#
# License:
# MIT License
#
# Copyright (c) 2025 Sebos Technology
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM,
# OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# =========================================================

# Configuration
KNOCK_FILE="$HOME/knockd_ports"
KNOCK_SERVER="192.168.178.18"  # Change to your server's hostname or IP
SSH_PORT=22  # SSH port to check

# Ensure knockd is installed
if ! command -v knock &> /dev/null; then
    echo "Error: knock command not found. Please install knockd (e.g., 'apt install knockd' or 'yum install knock')."
    exit 1
fi

# Ensure the knock file exists
if [ ! -f "$KNOCK_FILE" ]; then
    echo "Error: Knock sequence file '$KNOCK_FILE' not found."
    exit 1
fi

# Read and convert the knock sequence (replace commas with spaces)
KNOCK_SEQUENCE=$(cat "$KNOCK_FILE" | tr ',' ' ')

# Ensure state parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <state>"
    echo "  state unlock - Open access using the knock sequence"
    echo "  state lock   - Close access using the reversed knock sequence"
    exit 1
fi

# Function to check if SSH is already open
is_ssh_open() {
    nc -z -w2 "$KNOCK_SERVER" $SSH_PORT &>/dev/null
    return $?  # Returns 0 if SSH is open, 1 if it's closed
}

# Determine the action
case "$1" in
    unlock)
        if is_ssh_open; then
            echo "SSH is already unlocked on $KNOCK_SERVER. No need to knock."
        else
            echo "Knocking to unlock on $KNOCK_SERVER with sequence: $KNOCK_SEQUENCE"
            knock -v "$KNOCK_SERVER" $KNOCK_SEQUENCE
        fi
        ;;
    lock)
        REVERSED_SEQUENCE=$(echo "$KNOCK_SEQUENCE" | awk '{for(i=NF; i>0; i--) printf $i" "; print ""}')
        echo "Knocking to lock on $KNOCK_SERVER with sequence: $REVERSED_SEQUENCE"
        knock -v "$KNOCK_SERVER" $REVERSED_SEQUENCE
        ;;
    *)
        echo "Error: Invalid state. Use 'unlock' or 'lock'."
        exit 1
        ;;
esac
