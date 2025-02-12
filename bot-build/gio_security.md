## **Protecting the GPIO Pins at the OS Level (Orange Pi 5 Plus, Ubuntu)**  
**Objective:** Prevent unauthorized access to **GPIO (General Purpose Input/Output) pins** on the **Orange Pi 5 Plus**.  

---

## **1. Why Secure GPIO?**
🔴 **Security Risks:**  
- **Unauthorized access:** Malicious processes or users can toggle GPIO pins, potentially controlling actuators, motors, or sensors.  
- **Malware attacks:** A compromised system could manipulate GPIO to interfere with robot operation.  
- **Electrical damage:** Incorrect GPIO settings (e.g., switching from input to output with high current) could damage hardware.  
- **Privilege escalation:** If GPIO access is not restricted, it could lead to security vulnerabilities.  

✅ **Security Goals:**  
- **Restrict GPIO access to authorized users/processes only.**  
- **Prevent accidental or malicious modifications.**  
- **Ensure proper GPIO permissions at startup.**  
- **Monitor and log GPIO access attempts.**  

---

## **2. Default GPIO Access in Linux**
- In **Linux**, GPIO pins are accessed via:  
  - `/sys/class/gpio/` (Legacy sysfs interface)  
  - `/dev/gpiochipX` (Newer `libgpiod` interface)  
- By default, **any user** can access `/sys/class/gpio/`, leading to security risks.  

---

## **3. Restrict GPIO Access Using udev Rules**
**🔹 Step 1: Create a GPIO Security Policy**  
By default, `/sys/class/gpio/` and `/dev/gpiochipX` are world-readable. We will:  
- **Restrict access to the root user and a specific GPIO group.**  
- **Deny non-privileged users from modifying GPIO settings.**  

**🔹 Step 2: Create a udev Rule for Secure GPIO Access**  
1️⃣ Create a new **udev rules file**:  
   ```bash
   sudo nano /etc/udev/rules.d/99-gpio-security.rules
   ```
2️⃣ Add the following rules:  
   ```
   # Restrict GPIO access to the 'gpio' group
   SUBSYSTEM=="gpio", KERNEL=="gpio*", GROUP="gpio", MODE="660"
   SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="660"

   # Prevent unauthorized users from modifying GPIO
   SUBSYSTEM=="gpio", ACTION=="add", RUN+="/bin/chmod 660 /sys/class/gpio/*"
   ```

3️⃣ **Apply the new rules**:  
   ```bash
   sudo groupadd gpio
   sudo usermod -aG gpio pi  # Replace 'pi' with your username
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

✅ **Now, only users in the `gpio` group can access GPIO.**  

---

## **4. Secure GPIO Permissions on Boot**
After rebooting, **udev rules** may reset. To ensure security on every boot:

1️⃣ **Edit `/etc/rc.local` to re-apply permissions on startup:**  
   ```bash
   sudo nano /etc/rc.local
   ```
2️⃣ **Add the following before `exit 0`:**  
   ```bash
   # Secure GPIO permissions on boot
   chmod 660 /sys/class/gpio/*
   chown root:gpio /sys/class/gpio/*
   ```
3️⃣ **Make `/etc/rc.local` executable:**  
   ```bash
   sudo chmod +x /etc/rc.local
   ```

✅ **Ensures GPIO security settings persist after reboots.**  

---

## **5. Monitor Unauthorized GPIO Access**
To detect unauthorized access attempts, use **auditd (Linux Audit System).**  

### **🔹 Step 1: Install and Enable auditd**
```bash
sudo apt install auditd -y
sudo systemctl enable auditd
sudo systemctl start auditd
```

### **🔹 Step 2: Add an Audit Rule for GPIO**
```bash
sudo auditctl -w /sys/class/gpio -p rwxa -k gpio_access
```
📜 **Explanation:**  
- `-w /sys/class/gpio` → Watch the GPIO directory  
- `-p rwxa` → Log **read, write, execute, and attribute changes**  
- `-k gpio_access` → Add a custom log tag  

### **🔹 Step 3: View Unauthorized Access Logs**
```bash
sudo ausearch -k gpio_access --start today
```
✅ **Now, any unauthorized GPIO access attempt will be logged!**  

---

## **6. Limit GPIO Access for Specific Applications**
For applications that require GPIO access, **use capabilities instead of root privileges**.

### **🔹 Option 1: Run the App as a Specific User**
```bash
sudo chown root:gpio /usr/bin/your_gpio_app
sudo chmod 750 /usr/bin/your_gpio_app
```
✅ **Only users in the `gpio` group can run the app.**  

### **🔹 Option 2: Use `capabilities` Instead of Running as Root**
```bash
sudo setcap cap_sys_rawio+ep /usr/bin/your_gpio_app
```
✅ **Allows GPIO access without full root privileges.**  

---

## **7. Summary: Security Checklist**
✅ **Restrict GPIO access with udev rules** (`/etc/udev/rules.d/99-gpio-security.rules`)  
✅ **Ensure permissions persist across reboots** (`/etc/rc.local`)  
✅ **Monitor unauthorized access** (`auditd + ausearch`)  
✅ **Use capabilities instead of running apps as root** (`setcap`)  
✅ **Use the `gpio` group to limit access**  

---

## **🚀 Next Steps**
Would you like an **automated script** to implement these security measures on your Orange Pi 5 Plus? 🔥
