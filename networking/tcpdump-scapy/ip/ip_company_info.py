import socket
import requests
"""
Filename: ip_company_info.py
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
class IPCompanyInfo:
    """
    A class to retrieve network-related information for a given IP address, 
    including DNS resolution and company ownership details.
    """
    def __init__(self, ip):
        self.ip = ip
        self.dns = None
        self.company = None
    
    def get_dns(self):
        """
        Retrieve the DNS hostname for the given IP address.
        """
        try:
            self.dns = socket.gethostbyaddr(self.ip)[0]
        except socket.herror:
            self.dns = "N/A"  # Return "N/A" if no DNS record is found
        return self.dns
    
    def get_company(self):
        """
        Retrieve the company details using the IPInfo API.
        """
        try:
            response = requests.get(f"https://ipinfo.io/{self.ip}/json", timeout=5)
            data = response.json()
            self.company = data.get("org", "Unknown")  # Default to "Unknown" if no company info is available
        except requests.RequestException:
            self.company = "Unknown"  # Handle network errors gracefully
        return self.company
    
    def get_info(self):
        """
        Retrieve both DNS and company information and return as a structured dictionary.
        """
        return {
            "ip": self.ip,
            "dns": self.get_dns(),
            "company": self.get_company()
        }
