#!/bin/bash
#!/bin/bash
# =========================================================
# Filename: update_knockd_ports.sh 
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

# Define paths
KNOCKD_MAIN_CONF="/etc/knockd.conf"
KNOCKD_PORTS_CONF="/etc/knockd_ports.conf"
PORT_FILE="/etc/knockd_ports"

# Generate 5 unique random ports (between 2000-65000)
NEW_PORTS=$(shuf -i 2000-65000 -n 3 | tr '\n' ',' | sed 's/,$//')

# Store ports in a file for clients
echo "$NEW_PORTS" > "$PORT_FILE"

# Generate the dynamic knockd port config
cat <<EOF > "$KNOCKD_PORTS_CONF"
[openSSH]
        sequence = $NEW_PORTS
        seq_timeout = 5
        command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
        tcpflags    = syn
[closeSSH]
        sequence    = $(echo "$NEW_PORTS" | awk -F, '{print $3","$2","$1}')
        seq_timeout = 5
        command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
        tcpflags    = syn
EOF
# Merge the static config with the dynamic part

cat <<EOF > "$KNOCKD_MAIN_CONF"
[options]
        UseSyslog
$(cat "$KNOCKD_PORTS_CONF")

EOF

# Restart knockd to apply changes
systemctl restart knockd

# Secure files
chmod 600 "$PORT_FILE" "$KNOCKD_MAIN_CONF" "$KNOCKD_PORTS_CONF"
chmod 644 "$PORT_FILE"
scp "$PORT_FILE" desktop:~/.
echo "Knockd ports updated: $NEW_PORTS"
