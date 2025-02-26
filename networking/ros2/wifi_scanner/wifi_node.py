
# =========================================================
# Filename: wifi_node.py
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
# =========================================================import sys
import rclpy
from rclpy.node import Node
from std_msgs.msg import String
import json
sys.path.append('/opt/robot/wifi_scanner/scanner')
from scanner import WiFiScanner  # Assuming your scanner script is saved as wifi_scanner.py

class WiFiScannerNode(Node):
    def __init__(self):
        super().__init__('wifi_scanner_node')
        self.publisher_ = self.create_publisher(String, 'wifi_scanner', 10)
        self.timer = self.create_timer(5.0, self.scan_and_publish)  # Scan every 5 seconds
        self.get_logger().info("WiFi Scanner Node has been started.")

    def scan_and_publish(self):
        networks = WiFiScanner.scan()
        networks_data = [network.__dict__ for network in networks]
        msg = String()
        msg.data = json.dumps(networks_data)
        self.publisher_.publish(msg)
        self.get_logger().info(f"Published {len(networks)} WiFi networks.")


def main(args=None):
    rclpy.init(args=args)
    node = WiFiScannerNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
