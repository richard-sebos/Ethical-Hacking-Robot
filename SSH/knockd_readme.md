## **README: Port Knocking and Dynamic Port Rotation Scripts**  

This README provides an overview of the scripts and configurations used in the **Port Knocking** and **Dynamic Port Rotation** articles. These scripts enhance SSH security by controlling access via knock sequences and periodically updating knockd ports for additional security.  

---

### **1. Port Knocking Configuration**  

#### **File: `/etc/knockd.conf` - [code](SSH/etc/knockd.conf)**  
This is the main **knockd** configuration file, defining the knock sequences for opening and closing SSH access.  

---

### **2. knockd Service Configuration**  

#### **File: `/etc/default/knockd`- [code](SSH/etc/default/knockd)**  
This file enables `knockd` on startup and specifies the network interface to listen on.  


To enable and start `knockd`:  
```bash
sudo systemctl daemon-reload
sudo systemctl enable knockd
sudo systemctl start knockd
sudo systemctl status knockd
```

---

### **3. Firewall Rules for Port Knocking**  

#### **Commands to Set Up Firewall Rules:**  

```bash
# Keep current SSH connections active  
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT  

# Block SSH access by default  
sudo iptables -A INPUT -p tcp --dport 22 -j REJECT  
```

These rules ensure SSH is **blocked** by default, and `knockd` dynamically updates the firewall when the correct knock sequence is received.  

---

### **4. Dynamic Port Rotation Script**  

#### **File: `/usr/local/bin/update_knockd_ports.sh`**  
This script **randomizes knock sequences** and updates the `knockd` configuration dynamically.  

---

### **5. Automating Port Rotation with systemd**  

#### **File: `/etc/systemd/system/update-knockd.service`**  
This **systemd service** runs the port rotation script.  


#### **File: `/etc/systemd/system/update-knockd.timer`**  
This **systemd timer** schedules the script to run daily.  
``

#### **Enable and Start Timer:**  

```bash
sudo systemctl daemon-reload
sudo systemctl enable update-knockd.timer
sudo systemctl start update-knockd.timer
sudo systemctl status update-knockd.timer
```

---

### **6. Client-Side Knock Script**  

#### **File: `/usr/local/bin/knock_server.sh`**  
This script allows the client to send the correct knock sequence to **unlock** or **lock** SSH access.  



---

### **Conclusion**  

This README provides an overview of the **Port Knocking** and **Dynamic Port Rotation** setup, including:  
✅ `knockd` Configuration  
✅ Firewall Rules  
✅ Port Rotation Script  
✅ systemd Automation  
✅ Client-Side Implementation  

By following these configurations, you can **harden SSH security** and automate port rotation for **extra protection**. 🚀  

---

Let me know if you'd like any refinements! 😊
