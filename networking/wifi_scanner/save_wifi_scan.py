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
