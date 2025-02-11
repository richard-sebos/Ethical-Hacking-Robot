# **Security Design Document for Autonomous Robot Firewall**  
**Version:** 1.0  
**Date:** Feb 11, 2025  
**Author:** Richard Chamberlain / Sebos Technology

---

## **1. Introduction**  
### **1.1 Purpose**  
This document defines the **security architecture and design** for the autonomous robot’s firewall system. The security framework is designed to **protect network communications, GPS location data, Samba file sharing, and remote access** while ensuring the robot remains operational and resilient against cyber threats.  

### **1.2 Scope**  
The design applies to:  
- **Network security** (WiFi access point, RJ45, VPN, firewall rules)  
- **Access control** (SSH, Web Console, VPN)  
- **Intrusion detection & prevention** (Suricata, Fail2Ban)  
- **Data encryption & secure storage** (Samba & GPS security)  
- **GPS security** (Anti-spoofing, Geofencing, Secure APIs)  

---

## **2. Security Architecture Overview**
The security framework consists of **five core layers**:

| **Layer** | **Function** |
|-----------|-------------|
| **1. Perimeter Security (Firewall & VPN)** | Protects external access points (WiFi, LAN, SSH, Web Console) |
| **2. Network Security (Access Control & Isolation)** | Prevents unauthorized access using VLANs, MAC filtering, and WPA3 |
| **3. Intrusion Detection & Prevention (IDS/IPS)** | Monitors and blocks attacks using **Suricata & Fail2Ban** |
| **4. Data Security & Encryption** | Protects sensitive data (GPS, Samba files) with encryption |
| **5. Monitoring & Logging** | Captures security logs for auditing and incident response |

---

## **3. Security Components & Design**
### **3.1 Perimeter Security (Firewall & VPN)**
📌 **Objective:** Protect the robot from unauthorized access and cyber threats.  

#### **🔹 Firewall Design (firewalld + nftables)**
The firewall follows a **default-deny policy**, blocking all traffic except essential services.  

**Allowed Services & Ports:**
| **Service** | **Port** | **Reason** |
|------------|--------|-------------|
| **SSH** | 22 | Secure shell access |
| **HTTP(S)** | 80, 443 | Web console access |
| **WireGuard VPN** | 51820 | Secure remote access |
| **NTP** | 123 | GPS time synchronization |

#### **🔹 VPN Design (WireGuard)**
All remote access must go through **WireGuard VPN** to ensure encrypted communications.

**VPN Configuration:**
```ini
[Interface]
PrivateKey = <robot_private_key>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <admin_public_key>
AllowedIPs = 10.0.0.2/32
```
✅ **Only authorized devices can connect remotely.**  

---

### **3.2 Network Security (Access Control & Isolation)**
📌 **Objective:** Prevent unauthorized devices from connecting to the robot’s network.

#### **🔹 WiFi Security**
- The robot acts as an **Access Point (AP)** using `hostapd`  
- **WPA3 encryption** is enabled to prevent sniffing  
- **MAC filtering** allows only trusted devices  

#### **🔹 VLAN-Based Network Isolation**
| **Network** | **Devices** | **VLAN ID** |
|------------|------------|-------------|
| **Robot Admin Network** | SSH, Web Console, VPN | VLAN 10 |
| **User WiFi (Public)** | External devices | VLAN 20 |
| **Robot Sensors & GPS** | Internal system | VLAN 30 |

✅ **Prevents lateral movement between networks.**  

#### **🔹 IP Whitelisting for SSH**
Only trusted IPs can access SSH:
```bash
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.100/24" accept'
sudo firewall-cmd --reload
```
✅ **Blocks unauthorized SSH access!**  

---

### **3.3 Intrusion Detection & Prevention (IDS/IPS)**
📌 **Objective:** Detect and block cyber threats in real-time.

#### **🔹 Suricata IDS/IPS Deployment**
Suricata monitors network traffic for suspicious activity:
```yaml
af-packet:
  interface: eth0  # Monitor traffic on eth0
```
✅ **Alerts and blocks intrusion attempts.**  

#### **🔹 Fail2Ban for Brute Force Protection**
Fail2Ban blocks repeated failed login attempts for SSH and Samba.
```bash
sudo nano /etc/fail2ban/jail.local
```
Add:
```
[sshd]
enabled = true
maxretry = 3
bantime = 3600
```
✅ **Blocks attackers after 3 failed SSH login attempts!**  

---

### **3.4 Data Security & Encryption**
📌 **Objective:** Protect sensitive data stored and transmitted by the robot.

#### **🔹 GPS Security**
- **Restrict GPS hardware access:**
  ```bash
  sudo chmod 600 /dev/ttyUSB0
  ```
- **Encrypt GPS data at rest using eCryptfs**
  ```bash
  sudo ecryptfs-migrate-home -u gpsuser
  ```
- **Use Multi-GNSS (GPS + Galileo + GLONASS) to prevent spoofing.**

✅ **Prevents GPS data tampering & spoofing!**  

#### **🔹 Samba File Security**
- **Disable SMB1:**  
  ```ini
  [global]
  min protocol = SMB2
  smb encrypt = required
  ```
- **Restrict Samba access by IP:**  
  ```ini
  hosts allow = 192.168.1.0/24
  hosts deny = 0.0.0.0/0
  ```
✅ **Prevents unauthorized access & encryption attacks!**  

---

### **3.5 Monitoring & Logging**
📌 **Objective:** Capture security events and detect anomalies.

| **Log Type** | **Location** | **Purpose** |
|-------------|------------|------------|
| **Firewall logs** | `/var/log/firewalld.log` | Tracks blocked traffic |
| **Suricata logs** | `/var/log/suricata/fast.log` | Detects network threats |
| **Fail2Ban logs** | `/var/log/fail2ban.log` | Monitors brute force attacks |

**🔹 Log Aggregation & Alerts**
- Use **Syslog** to centralize logs:
  ```bash
  sudo systemctl enable rsyslog
  ```
- Configure **email alerts** for security breaches.

✅ **Notifies admins of security threats in real-time!**  

---

## **4. Security Implementation Diagram**
📌 **High-Level Security Design**
```
             +---------------------+
             |  Admin Workstation  |
             |  (VPN, SSH, Web)    |
             +---------+-----------+
                       |
                       | WireGuard VPN
                       |
+----------------------+---------------------+
|               Robot Firewall               |
|--------------------------------------------|
| Firewalld + nftables (Perimeter Security)  |
| VLAN Isolation (WiFi, LAN, Sensors)        |
| Suricata IDS/IPS (Threat Detection)        |
| Fail2Ban (Brute Force Protection)          |
| GPS Security (Anti-Spoofing)               |
| Samba Hardening (Encrypted Shares)         |
+--------------------------------------------+
                       |
                       |
            +----------+-----------+
            |  Robot Sensors (GPS) |
            |  Web Console         |
            |  WiFi Access Point   |
            +----------------------+
```
✅ **Defense-in-depth security architecture!**  

---

## **5. Conclusion**
This security design ensures that **the robot remains secure** against network attacks, unauthorized access, and data breaches. The combination of **firewall rules, intrusion detection, encryption, and secure remote access** provides a **comprehensive security framework**.
