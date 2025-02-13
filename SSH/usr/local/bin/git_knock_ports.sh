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

## Encrypt Info
ENCRYPTED_PORT_FILE="/etc/knockd_ports.gpg"

## Local repo dir
GITHUB_DIR="/opt/github-sec/"
REPO="ports"
SERVICE_ID="OPI0"
GIT_PORT_PATH=${GITHUB_DIR}/${REPO}/${SERVER_ID}/knock_ports

## Setup github connection 
GITHUB_REPO_URL="git@github.com:richard-sebos/knock-ports"
GPG_RECIPIENT="your-gpg-key-id"
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


# Encrypt the port file
gpg --yes --encrypt --recipient "$GPG_RECIPIENT" -o "$GIT_PORT_FILE" "$PORT_FILE"

# Ensure the Git repository exists
if [ ! -d "$GITHUB_REPO_DIR" ]; then
    git clone "$GITHUB_REPO_URL" "$GITHUB_REPO_DIR"
fi


# Commit and push changes to GitHub
cd "$GITHUB_REPO_DIR"
git add <need var>
git commit -m "Updated knockd ports on $(date)"
git push origin main
echo "Knockd ports updated and encrypted file pushed to GitHub: $NEW_PORTS"
