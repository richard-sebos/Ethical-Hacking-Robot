#!/bin/bash
"""
Filename: pcap-capture.sh
Company: Sebos Technology
Date: 2025-02-04
Author: Sebos Technology Team

License:
MIT License

Copyright (c) 2025 Sebos Technology

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM,
OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

2025-02-04 - Down interfaces cause error, and this was corrected

"""
# Load config
CONFIG_FILE="/etc/pcap-capture.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file $CONFIG_FILE not found!"
    exit 1
fi
source "$CONFIG_FILE"

# Check permission file
if [[ ! -f "$PERMISSION_FILE" ]]; then
    echo "Permission file not found! Exiting."
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Set proper permissions for output directory (owned by root but accessible)
chmod 777 "$OUTPUT_DIR"

# Remove old .pcap files before starting a new capture session
echo "Clearing previous capture files in $OUTPUT_DIR..."
find "$OUTPUT_DIR" -name "*.pcap" -type f -delete

# Get all active interfaces except loopback
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo")

# Function to check if an interface is up
is_interface_up() {
    local iface=$1
    ip link show "$iface" | grep -q "state UP"
}

# Function to get subnet for an interface
get_subnet() {
    local iface=$1

    # Ensure interface is up before fetching IP information
    if ! is_interface_up "$iface"; then
        echo "Interface $iface is down. Skipping..."
        return 1
    fi

    local ip_info=$(ip -o -f inet addr show "$iface" | awk '{print $4}')
    
    # Skip interface if no valid IP found
    if [[ -z "$ip_info" ]]; then
        return 1
    fi


    local ip_info=$(ip -o -f inet addr show "$iface" | awk '{print $4}')
    
    # Skip interface if no valid IP found
    if [[ -z "$ip_info" ]]; then
        return 1
    fi

    local ip_address=$(echo "$ip_info" | cut -d/ -f1)  # Extract IP address (e.g., 192.168.178.14)
    local cidr=$(echo "$ip_info" | cut -d/ -f2)        # Extract CIDR prefix (e.g., 24)

    # Ensure CIDR is valid
    if [[ -z "$cidr" ]]; then
        return 1
    fi

    # Calculate the network address using bitwise AND
    local network=$(python3 -c "import ipaddress; print(ipaddress.IPv4Network('$ip_info', strict=Fal>

    # Return network and CIDR if valid
    if [[ -n "$network" ]]; then
        echo "$network/$cidr"
    else
        return 1
    fi
}

# Start capturing on each interface separately
for IFACE in $INTERFACES; do
    # Check if interface is up before processing
    if ! is_interface_up "$IFACE"; then
        echo "Skipping $IFACE as it is down."
        continue
    fi

    SUBNET=$(get_subnet "$IFACE")

    if [[ -z "$SUBNET" ]]; then
        echo "No valid IPv4 subnet found for $IFACE. Skipping..."
        continue
    fi

    # Create an interface-specific directory
    IFACE_DIR="$OUTPUT_DIR/$IFACE"
    mkdir -p "$IFACE_DIR"
    chmod 777 "$IFACE_DIR"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    FILE="$IFACE_DIR/${BASE_FILENAME}_$TIMESTAMP.pcap"

    echo "Starting capture on $IFACE for subnet $SUBNET -> $FILE"

    # Run tcpdump in the background for each interface
    echo "tcpdump -i \"$IFACE\" net \"$SUBNET\" -w \"$FILE\" -C \"$FILE_SIZE_MB\" -G \"$ROTATE_SECON>
    tcpdump -i "$IFACE" net "$SUBNET" -w "$FILE" -C "$FILE_SIZE_MB" -G "$ROTATE_SECONDS" -z gzip &
done

echo "Packet capture started for all active interfaces."
