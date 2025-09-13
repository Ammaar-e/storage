#!/bin/bash
# reset-template.sh
# Reset unique identifiers on cloned Ubuntu VM

set -e

echo "[*] Resetting machine identifiers..."

# Regenerate machine-id
sudo rm -f /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo systemd-machine-id-setup

# Reset SSH host keys
echo "[*] Removing old SSH host keys..."
sudo rm -f /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server

# Clear DHCP leases
echo "[*] Clearing DHCP leases..."
sudo rm -f /var/lib/dhcp/*

# Prompt for new hostname
read -rp "Enter new hostname: " NEW_HOSTNAME
if [ -n "$NEW_HOSTNAME" ]; then
    echo "[*] Setting hostname to $NEW_HOSTNAME"
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"
    # Update /etc/hosts entry
    sudo sed -i "/127.0.1.1/d" /etc/hosts
    echo "127.0.1.1   $NEW_HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
else
    echo "[!] No hostname entered, skipping."
fi

# Cleanup logs
echo "[*] Cleaning up logs..."
sudo truncate -s 0 /var/log/wtmp
sudo truncate -s 0 /var/log/btmp
sudo truncate -s 0 /var/log/lastlog

echo "[*] Reset complete. Reboot recommended."
