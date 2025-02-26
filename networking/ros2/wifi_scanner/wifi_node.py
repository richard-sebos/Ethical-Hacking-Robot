import sys
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
