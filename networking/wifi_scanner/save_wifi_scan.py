# =========================================================
# Filename: save_wifi_scan.py
# Company: Sebos Technology
# Date: 2025-02-20
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

import subprocess
from scanner.scanner import WiFiScanner
from scanner.storage import WiFiStorage

def log_message(message):
    """Log messages to systemd journal."""
    subprocess.run(["logger", "-t", "WiFiScanner", message])

def scan_and_save():
    scanner = WiFiScanner()
    storage = WiFiStorage()

    wifi_networks = scanner.scan()

    if not wifi_networks:
        log_message("No WiFi networks found.")
        return

    for network in wifi_networks:
        storage.add_network(network)
        log_message(f"Saved WiFi Network: {network.ssid} ({network.bssid})")

    log_message("WiFi scan completed successfully!")

if __name__ == "__main__":
    log_message("Starting WiFi scan...")
    scan_and_save()
