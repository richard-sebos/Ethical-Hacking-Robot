#!/bin/bash

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

# Function to get subnet for an interface
get_subnet() {
    local iface=$1
    local ip_info=$(ip -o -f inet addr show "$iface" | awk '{print $4}')
    local ip_address=$(echo "$ip_info" | cut -d/ -f1)  # Extract IP address (e.g., 192.168.178.14)
    local cidr=$(echo "$ip_info" | cut -d/ -f2)        # Extract CIDR prefix (e.g., 24)

    # Calculate the network address using bitwise AND
    local network=$(python3 -c "import ipaddress; print(ipaddress.IPv4Network('$ip_info', strict=False).network_address)")
    
    echo "$network/$cidr"
}

# Start capturing on each interface separately
for IFACE in $INTERFACES; do
    SUBNET=$(get_subnet "$IFACE")

    if [[ -z "$SUBNET" ]]; then
        echo "No valid IPv4 subnet found for $IFACE. Skipping..."
        continue
    fi

    # Create an interface-specific directory
    IFACE_DIR="$OUTPUT_DIR/$IFACE"
    mkdir -p "$IFACE_DIR"

    TIMESTAMP="%Y%m%d_%H%M%S"
    FILE="$IFACE_DIR/${BASE_FILENAME}_$TIMESTAMP.pcap"

    echo "Starting capture on $IFACE for subnet $SUBNET -> $FILE"

    # Run tcpdump in the background for each interface
    echo "tcpdump -i "$IFACE" net "$SUBNET" -w "$FILE" -C "$FILE_SIZE_MB" -G "$ROTATE_SECONDS" -z gzip"
    tcpdump -i "$IFACE" net "$SUBNET" -w "$FILE" -C "$FILE_SIZE_MB" -G "$ROTATE_SECONDS" -z gzip &
done


echo "Packet capture started for all interfaces."

