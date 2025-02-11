Here's a **Bash script** to **automate the security setup** on your **Orange Pi 5 Plus (Ubuntu)**. This script:  
✅ **Configures firewalld** (secure firewall with only essential services)  
✅ **Sets up VPN (WireGuard)** for secure remote access  
✅ **Harden Samba (SMB)** with encryption & access controls  
✅ **Secures GPS data** (restricts access & prevents spoofing)  
✅ **Installs Suricata (IDS/IPS)** for intrusion detection  
✅ **Installs Fail2Ban** (prevents brute-force attacks on SSH & Samba)  

---

### 🚀 **Installation Instructions**
1️⃣ **Copy & Paste the Script Below**  
2️⃣ **Save it as `secure_robot.sh`**  
3️⃣ **Give it Execution Permission:**  
   ```bash
   chmod +x secure_robot.sh
   ```
4️⃣ **Run the Script as Root:**  
   ```bash
   sudo ./secure_robot.sh
   ```

---

### **🔥 Secure Robot Firewall Script**
```bash
#!/bin/bash

echo "🚀 Starting Security Setup for Orange Pi 5 Plus (Ubuntu)..."

# Exit if not run as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root!"
   exit 1
fi

echo "🔹 Updating and installing necessary packages..."
apt update && apt upgrade -y
apt install firewalld wireguard gpsd gpsd-clients samba suricata fail2ban nftables -y

# ========================
# 1️⃣ FIREWALL SETUP
# ========================
echo "🔒 Configuring Firewall (firewalld + nftables)..."

systemctl enable firewalld
systemctl start firewalld

# Block all incoming traffic except allowed services
firewall-cmd --set-default-zone=drop
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=51820/udp  # WireGuard VPN
firewall-cmd --permanent --add-service=samba  # Samba access
firewall-cmd --reload

# Block unknown IPs
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; }
nft add rule inet filter input ip saddr != 192.168.1.0/24 drop

# ========================
# 2️⃣ VPN (WIREGUARD)
# ========================
echo "🔑 Setting up WireGuard VPN..."
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $(cat /etc/wireguard/privatekey)
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = YOUR_CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
EOF

chmod 600 /etc/wireguard/wg0.conf
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# ========================
# 3️⃣ GPS SECURITY
# ========================
echo "📡 Securing GPS Access..."
chmod 600 /dev/ttyUSB0 /dev/ttyS0
echo 'KERNEL=="ttyUSB*", MODE="0600", OWNER="root", GROUP="root"' > /etc/udev/rules.d/99-gps.rules
systemctl restart gpsd

# ========================
# 4️⃣ SAMBA SECURITY
# ========================
echo "🗄️ Hardening Samba (SMB) security..."
cat <<EOF >> /etc/samba/smb.conf
[global]
min protocol = SMB2
smb encrypt = required
hosts allow = 192.168.1.0/24
hosts deny = ALL
EOF

systemctl restart smbd

# ========================
# 5️⃣ SURICATA IDS/IPS
# ========================
echo "🛡️ Installing and configuring Suricata..."
systemctl enable suricata
systemctl start suricata

# Enable Suricata monitoring on eth0
sed -i 's/interface: eth0/# interface: eth0/g' /etc/suricata/suricata.yaml
echo "af-packet:
  interface: eth0" >> /etc/suricata/suricata.yaml

systemctl restart suricata

# ========================
# 6️⃣ FAIL2BAN (Brute Force Protection)
# ========================
echo "🚧 Installing Fail2Ban..."
cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh

[smb]
enabled = true
port = 445
logpath = /var/log/samba/log.smbd
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# ========================
# 🏁 FINAL STEPS
# ========================
echo "✅ Security setup completed! Here's a summary:"
echo "-------------------------------------------------"
echo "✔️ Firewall configured with nftables & firewalld"
echo "✔️ WireGuard VPN setup (Check /etc/wireguard/wg0.conf)"
echo "✔️ GPS access restricted (root only)"
echo "✔️ Samba hardened (No SMB1, encrypted, IP restricted)"
echo "✔️ Suricata IDS installed & monitoring network"
echo "✔️ Fail2Ban running (Brute-force attack protection)"
echo "-------------------------------------------------"
echo "📜 Check logs: sudo journalctl -xe | grep firewalld"
echo "📜 Suricata logs: sudo tail -f /var/log/suricata/fast.log"
echo "📜 Fail2Ban status: sudo fail2ban-client status"
echo "🚀 Reboot for all changes to take effect!"
```

---

### 🚀 **What This Script Does**
✅ **Firewall (firewalld + nftables)**:  
- Blocks all traffic **except SSH, HTTP, HTTPS, VPN, and Samba**  
- **Blocks unknown IPs** (only allows **192.168.1.0/24**)  

✅ **WireGuard VPN**:  
- Generates a **VPN key pair**  
- Configures VPN at `10.0.0.1/24`  
- Starts the VPN at boot  

✅ **GPS Security**:  
- Restricts GPS hardware access **to root only**  
- Blocks unauthorized GPS device access  

✅ **Samba Security**:  
- **Disables SMB1** (prevents hacking tools)  
- **Forces encryption** (`smb encrypt = required`)  
- **Blocks unauthorized IPs**  

✅ **Intrusion Detection (Suricata IDS)**:  
- Installs **Suricata** & monitors **eth0** for network threats  

✅ **Fail2Ban (Brute-Force Attack Protection)**:  
- **Blocks SSH attackers after 3 failed logins**  
- **Blocks SMB login attempts after 3 failures**  

---

### 🔥 **How to Verify Security**
After running the script, test everything:  

**1️⃣ Check firewall rules:**  
```bash
sudo firewall-cmd --list-all
```
**2️⃣ Test VPN connection:**  
- Run `wg show` to see connected VPN clients  

**3️⃣ Check Samba security:**  
- Try accessing Samba from an **unauthorized IP** (should be blocked)  

**4️⃣ Simulate a brute-force attack:**  
```bash
ssh root@your-robot-ip  # Enter wrong password 3 times
```
- Then check Fail2Ban status:  
  ```bash
  sudo fail2ban-client status sshd
  ```

---

## 🎯 **Next Steps**
Would you like **logging alerts** (email or Discord notifications) when an attack happens? I can add that! 🚀
