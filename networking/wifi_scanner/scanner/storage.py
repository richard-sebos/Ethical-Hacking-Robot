# =========================================================
# Filename: storage.py
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
import sqlite3
from scanner.scanner import SSID
from typing import List, Optional

class WiFiStorage:
    def __init__(self, db_name: str = "/srv/database/robot.db"):
        self.db_name = db_name
        self._create_table()

    def _create_table(self):
        """Creates the WiFi networks table if it doesn't exist."""
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS wifi_networks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    bssid TEXT,
                    ssid TEXT,
                    channel INTEGER,
                    rate TEXT,
                    bars INTEGER,
                    security TEXT,
                    timestamp TEXT,
                    frequency REAL,
                    signal_strength INTEGER
                )
            ''')
            conn.commit()

    def add_network(self, network: SSID):
        """Inserts a new WiFi network into the database."""
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO wifi_networks (bssid, ssid, channel, rate, bars, security, timestamp, frequency, signal_strength)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                (network.bssid, network.ssid, network.channel, network.rate, network.bars, network.security, network.timestamp, network.frequency, network.signal_strength)
            )
            conn.commit()

    def get_all_networks(self) -> List[SSID]:
        """Retrieves all WiFi networks from the database."""
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM wifi_networks")
            rows = cursor.fetchall()
            return [SSID(*row[1:]) for row in rows]
    def get_network_by_bssid(self, bssid: str) -> Optional[SSID]:
        """Fetches a network by its BSSID."""
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM wifi_networks WHERE bssid = ?", (bssid,))
            row = cursor.fetchone()
            return SSID(*row[1:]) if row else None

    def update_network(self, bssid: str, new_data: SSID):
        """Updates an existing WiFi network record."""
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE wifi_networks SET ssid=?, channel=?, rate=?, bars=?, security=?, timestamp=?, frequency=?, signal_strength=?
                WHERE bssid=?''',
                (new_data.ssid, new_data.channel, new_data.rate, new_data.bars, new_data.security, new_data.timestamp, new_data.frequency, new_data.signal_strength, bssid)
            )
            conn.commit()

    def delete_network(self, bssid: str):
        """Deletes a WiFi network from the database."""
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM wifi_networks WHERE bssid = ?", (bssid,))
            conn.commit()

if __name__ == "__main__":
    storage = WiFiStorage()

    # Example Usage
    wifi = SSID("00:11:22:33:44:55", "HomeWiFi", 6, "150 Mbps", 4, "WPA2", "2025-02-20T12:00:00", 2.437, -50)
    storage.add_network(wifi)
    print(storage.get_all_networks())

