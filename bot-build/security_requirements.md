# **Security Requirements Document for Autonomous Robot Firewall**  
**Version:** 1.0  
**Date:** *Feb 11, 2025*  
**Author:** *(Richard Chamberlain / Sebos Technology)*  

---

## **1. Introduction**  
### **1.1 Purpose**  
This document outlines the **security requirements** for the autonomous robot’s firewall system. The goal is to **prevent unauthorized access, protect data, and mitigate cyber threats** while ensuring smooth operation.  

### **1.2 Scope**  
This applies to the **robot’s network security, GPS security, Samba file sharing, remote access, and firewall configuration**. It covers:  
- **Network security (WiFi, RJ45, VPN, firewall rules)**  
- **Access control (SSH, Web Console, VPN)**  
- **Intrusion detection & prevention (Suricata, Fail2Ban)**  
- **Data encryption & secure storage**  
- **GPS security (anti-spoofing, location validation)**  

---

## **2. Security Requirements**  
### **2.1 Network Security**  
| **ID** | **Requirement** | **Description** | **Priority** |  
|--------|---------------|----------------|------------|  
| SEC-01 | Default-Deny Policy | The firewall must block all incoming traffic **except** for explicitly allowed services. | High |  
| SEC-02 | Separate Zones | The **robot’s WiFi access point**, LAN (RJ45), and external connections must be **isolated** using firewall zones. | High |  
| SEC-03 | Secure WiFi | The robot’s access point must use **WPA3** and **MAC filtering** to allow only authorized devices. | High |  
| SEC-04 | Secure VPN | All **remote connections** must use **WireGuard VPN** with strong encryption. | High |  
| SEC-05 | Disable Insecure Protocols | **SMB1 and Telnet** must be disabled to prevent MITM attacks. | High |  
| SEC-06 | Logging & Monitoring | Firewall logs must be stored and analyzed for unauthorized access attempts. | Medium |  

---

### **2.2 Firewall Configuration**  
| **ID** | **Requirement** | **Description** | **Priority** |  
|--------|---------------|----------------|------------|  
| FW-01 | Firewalld Enforcement | The system must use **firewalld** with **nftables** as the default firewall backend. | High |  
| FW-02 | Allowed Services | The firewall must only allow **SSH (22), HTTP (80, 443), VPN (51820)**, and other required ports. | High |  
| FW-03 | Block Unauthorized IPs | The system must block connections **outside a trusted IP range**. | High |  
| FW-04 | Intrusion Prevention | **Suricata** must detect and block network-based attacks. | High |  
| FW-05 | Rate Limiting | Limit SSH and web login attempts to prevent brute-force attacks. | Medium |  
| FW-06 | Port Knocking | Require **port knocking** for SSH access to reduce attack surface. | Low |  

---

### **2.3 GPS Security**  
| **ID** | **Requirement** | **Description** | **Priority** |  
|--------|---------------|----------------|------------|  
| GPS-01 | Secure Device Access | Only **root** should be allowed to access **GPS hardware (ttyUSB0/ttyS0)**. | High |  
| GPS-02 | GPSD Access Control | GPS data must be handled via **GPSD**, restricting direct hardware access. | High |  
| GPS-03 | Anti-Spoofing | The system must verify GPS coordinates against expected locations to detect spoofing. | Medium |  
| GPS-04 | Multi-GNSS Support | The robot should use **multi-GNSS (GPS + Galileo + GLONASS)** for improved security. | Medium |  
| GPS-05 | Geofencing | If the robot moves **outside a predefined area**, generate an alert. | Medium |  

---

### **2.4 Samba (File Sharing) Security**  
| **ID** | **Requirement** | **Description** | **Priority** |  
|--------|---------------|----------------|------------|  
| SMB-01 | Enforce Encryption | Samba traffic must be encrypted (`smb encrypt = required`). | High |  
| SMB-02 | Disable SMB1 | The robot must **disable SMB1** and enforce SMB2/SMB3. | High |  
| SMB-03 | Restrict IPs | Only allow **trusted IP ranges** to connect to Samba shares. | High |  
| SMB-04 | User Authentication | Require **username/password authentication** for all shared files. | High |  
| SMB-05 | Fail2Ban Protection | If a user **fails login attempts 3 times**, block their IP. | Medium |  
| SMB-06 | Encrypted Storage | Samba-shared files should be stored in an **encrypted volume (eCryptfs)**. | Medium |  

---

### **2.5 Secure Remote Access**  
| **ID** | **Requirement** | **Description** | **Priority** |  
|--------|---------------|----------------|------------|  
| VPN-01 | WireGuard VPN | All remote connections must use **WireGuard** for encryption. | High |  
| VPN-02 | Limit VPN Users | Only **trusted users** with keys should be able to access the robot. | High |  
| VPN-03 | SSH Port Knocking | SSH must require **port knocking** before allowing connections. | Medium |  
| VPN-04 | 2FA for Web Console | The **robot's web-based admin panel** must require **Two-Factor Authentication (2FA)**. | Medium |  

---

### **2.6 Intrusion Detection & Monitoring**  
| **ID** | **Requirement** | **Description** | **Priority** |  
|--------|---------------|----------------|------------|  
| IDS-01 | Suricata IDS | The system must use **Suricata** to detect network intrusions. | High |  
| IDS-02 | Log Monitoring | Firewall logs must be **monitored and analyzed** for anomalies. | High |  
| IDS-03 | Alert System | If an attack is detected, send an **alert to the administrator**. | Medium |  
| IDS-04 | Fail2Ban | Protect SSH & Samba from **brute-force attacks**. | High |  
| IDS-05 | Regular Updates | The system must apply **firewall & IDS rule updates** automatically. | Medium |  

---

## **3. Security Implementation Plan**
| **Phase** | **Task** | **Responsible Party** | **Deadline** |
|----------|---------|----------------|----------|
| **Phase 1** | Set up **firewalld** & firewall rules | DevOps Team | *(Date)* |
| **Phase 2** | Configure **GPS security (GPSD, anti-spoofing, geofencing)** | Robot Engineers | *(Date)* |
| **Phase 3** | Harden **Samba security (disable SMB1, encryption, IP restrictions)** | IT Security | *(Date)* |
| **Phase 4** | Implement **WireGuard VPN & SSH security** | Network Team | *(Date)* |
| **Phase 5** | Deploy **Suricata IDS & Fail2Ban** | Cybersecurity Team | *(Date)* |

---

## **4. Security Compliance & Testing**
1. **Penetration Testing**  
   - Simulate **network attacks (MITM, brute force, spoofing)**  
   - Run **Nmap scans** to test firewall strength  
   - Test **Samba access control & Fail2Ban**  
   
2. **Security Audit**  
   - Review firewall logs for suspicious activity  
   - Ensure **GPS security features** are working  

3. **Incident Response Plan**  
   - If an attack is detected, notify **admin immediately**  
   - Log all **intrusion attempts** for analysis  

---

## **5. Conclusion**
This security framework ensures the **robot's firewall, network, GPS, and file-sharing security** are fully protected. **All security features must be tested regularly** to prevent cyber threats.
