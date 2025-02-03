"""
Filename: pcap_processot.py
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
import os
import glob
import ipaddress
from scapy.all import rdpcap, IP
from ip.ip_company_info import IPCompanyInfo
class PCAPProcessor:
    """
    A class to process PCAP files and track internal and external packet counts.
    """
    def __init__(self, pcap_dir):
        self.pcap_dir = pcap_dir
        self.external_ips = {}
        self.internal_packet_count = 0
        self.external_packet_count = 0
    
    def _is_private_ip(self, ip):
        """
        Check if an IP address is private.
        """
        try:
            return ipaddress.ip_address(ip).is_private
        except ValueError:
            return False  # In case an invalid IP is encountered
    
    def process_pcaps(self):
        """
        Process each PCAP file and categorize IPs as internal or external.
        """
        for pcap_file in glob.glob(os.path.join(self.pcap_dir, "*.pcap")):
            packets = rdpcap(pcap_file)
            for packet in packets:
                if IP in packet:
                    src_ip = packet[IP].src
                    dst_ip = packet[IP].dst

                    for ip in [src_ip, dst_ip]:
                        if self._is_private_ip(ip):
                            self.internal_packet_count += 1
                        else:
                            self.external_packet_count += 1
                            self.external_ips[ip] = self.external_ips.get(ip, 0) + 1

    def get_external_ip_info(self):
        """
        Retrieve details for external IPs.
        """
        ip_info = {}
        for ip, count in self.external_ips.items():
            net_info = IPCompanyInfo(ip)
            ip_info[ip] = {"dns": net_info.get_dns(), "company": net_info.get_company(), "packet_count": count}
        return ip_info
