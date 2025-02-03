"""
Filename: packet_count.py
Company: Sebos Technology
Date: 2025-02-02
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
"""
from  packets.pcap_processor import  PCAPProcessor
# Define the PCAP directory
PCAP_DIR = "../data"


def main():
    """
    Main function to process PCAP files and print results.
    """
    processor = PCAPProcessor(PCAP_DIR)
    processor.process_pcaps()
    ip_info = processor.get_external_ip_info()

    print("External IPs Found:\n")
    for ip, info in ip_info.items():
        print(f"IP: {ip}")
        print(f"  DNS: {info['dns']}")
        print(f"  Company: {info['company']}")
        print(f"  Packet Count: {info['packet_count']}")
        print("-" * 40)

    print(f"Internal Packet Count: {processor.internal_packet_count}")
    print(f"External Packet Count: {processor.external_packet_count}")

if __name__ == "__main__":
    main()
