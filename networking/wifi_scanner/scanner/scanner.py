# =========================================================
# Filename: scanner.py
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
# =========================================================import subprocess
import platform
import re
import datetime
from typing import List

class SSID:
    def __init__(self, bssid: str, ssid: str, channel: int, rate: str, bars: int, security: str, timestamp: str, frequency: float = None, signal_strength: int = None):
        self.bssid = bssid
        self.ssid = ssid
        self.channel = channel
        self.rate = rate
        self.bars = bars
        self.security = security
        self.timestamp = timestamp
        self.frequency = frequency
        self.signal_strength = signal_strength

    def __repr__(self):
        return f"SSID(ssid='{self.ssid}', bssid='{self.bssid}', channel={self.channel}, rate='{self.rate}', bars={self.bars}, security='{self.security}', timestamp='{self.timestamp}', frequency={self.frequency}, signal_strength={self.signal_strength})"

class WiFiScanner:
    @staticmethod
    def scan() -> List[SSID]:
        networks = []
        try:
            output = subprocess.check_output(["sudo", "iwlist", "wlx6c5ab01a0498", "scan"], stderr=subprocess.DEVNULL).decode("utf-8")
            raw_networks = output.split("Cell ")[1:]

            for net in raw_networks:
                bssid = re.search(r"Address: ([\w:\-]+)", net)
                ssid = re.search(r"ESSID:\"(.*?)\"", net)
                channel = re.search(r"Channel:(\d+)", net)
                rate = re.search(r"Bit Rates:(.*?)\n", net)
                security = "Open" if "Encryption key:off" in net else "Secure"
                signal_strength = re.search(r"Signal level=(-?\d+) dBm", net)
                frequency = re.search(r"Frequency:(\d+\.\d+)", net)
                bars = WiFiScanner._calculate_bars(int(signal_strength.group(1))) if signal_strength else 0
                timestamp = datetime.datetime.now().isoformat()

                networks.append(
                    SSID(
                        bssid.group(1) if bssid else "Unknown",
                        ssid.group(1) if ssid else "Hidden",
                        int(channel.group(1)) if channel else 0,
                        rate.group(1) if rate else "Unknown",
                        bars,
                        security,
                        timestamp,
                        float(frequency.group(1)) if frequency else None,
                        int(signal_strength.group(1)) if signal_strength else None,
                    )
                )
        except Exception as e:
            print(f"Error scanning WiFi networks: {e}")

        return networks
    @staticmethod
    def _calculate_bars(signal_strength: int) -> int:
        """ Convert signal strength (dBm) to a bar level (0-5). """
        if signal_strength >= -50:
            return 5
        elif signal_strength >= -60:
            return 4
        elif signal_strength >= -70:
            return 3
        elif signal_strength >= -80:
            return 2
        elif signal_strength >= -90:
            return 1
        return 0

if __name__ == "__main__":
    wifi_networks = WiFiScanner.scan()
