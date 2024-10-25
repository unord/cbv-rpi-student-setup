#!/bin/bash

# setup_static_ip.sh

# ------------------------------
# Configuration
# ------------------------------
# Define the path to the configuration file
CONFIG_FILE="./network_config.conf"

# ------------------------------
# Functions
# ------------------------------

# Function to display error messages and exit
error_exit() {
  echo "Error: $1"
  exit 1
}

# Function to validate IP address format
validate_ip() {
  local ip=$1
  local stat=1

  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    read -r -a octets <<< "$ip"
    IFS=$OIFS
    if [[ ${octets[0]} -le 255 && ${octets[1]} -le 255 \
      && ${octets[2]} -le 255 && ${octets[3]} -le 255 ]]; then
      stat=0
    fi
  fi
  return $stat
}

# Function to check if a variable is set
check_var() {
  local var_name=$1
  if [ -z "${!var_name}" ]; then
    error_exit "Configuration parameter '$var_name' is missing or empty in $CONFIG_FILE."
  fi
}

# ------------------------------
# Ensure the script is run as root
# ------------------------------
if [ "$EUID" -ne 0 ]; then
  error_exit "Please run this script as root using sudo."
fi

# ------------------------------
# Check if the configuration file exists
# ------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
  error_exit "Configuration file '$CONFIG_FILE' not found."
fi

# ------------------------------
# Source the configuration file
# ------------------------------
source "$CONFIG_FILE"

# ------------------------------
# Validate Configuration Parameters
# ------------------------------

# Wi-Fi Parameters
check_var "SSID"
check_var "PSK"
check_var "COUNTRY"

# Wi-Fi Static IP Parameters
check_var "SUBNET_WLAN"
check_var "GATEWAY_WLAN"
check_var "DNS_WLAN"

# Validate COUNTRY (must be a two-letter country code)
if [[ ! $COUNTRY =~ ^[A-Z]{2}$ ]]; then
  error_exit "Invalid COUNTRY code '$COUNTRY'. It should be a two-letter uppercase country code (e.g., US, DK)."
fi

# Validate SUBNET_WLAN (must start with a slash followed by 1-2 digits)
if [[ ! $SUBNET_WLAN =~ ^/[0-9]{1,2}$ ]]; then
  error_exit "Invalid SUBNET_WLAN '$SUBNET_WLAN'. It should be in CIDR notation, e.g., /24."
fi

# Validate GATEWAY_WLAN
if ! validate_ip "$GATEWAY_WLAN"; then
  error_exit "Invalid GATEWAY_WLAN IP address '$GATEWAY_WLAN'."
fi

# Validate DNS_WLAN (at least one valid IP)
for dns_ip in $DNS_WLAN; do
  if ! validate_ip "$dns_ip"; then
    error_exit "Invalid DNS_WLAN server IP address '$dns_ip'."
  fi
done

# ------------------------------
# Prompt for Hostname
# ------------------------------
read -p "Enter desired hostname: " NEW_HOSTNAME

# Validate hostname (simple validation)
if [[ ! $NEW_HOSTNAME =~ ^[a-zA-Z0-9\-]+$ ]]; then
  error_exit "Invalid hostname. Use only letters, numbers, and hyphens."
fi

# Prompt for static IP for Wi-Fi
read -p "Enter desired static IP address for Wi-Fi (e.g., 10.126.193.100): " STATIC_IP_WLAN

# Validate IP address
if ! validate_ip "$STATIC_IP_WLAN"; then
  error_exit "Invalid IP address format for Wi-Fi."
fi

# ------------------------------
# Update Hostname
# ------------------------------
echo "Updating hostname to '$NEW_HOSTNAME'..."
echo "$NEW_HOSTNAME" > /etc/hostname

# Update /etc/hosts
sed -i "s/127\.0\.1\.1\s\+.*/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts

# ------------------------------
# Configure Static IP for Wi-Fi
# ------------------------------

# Backup dhcpcd.conf
cp /etc/dhcpcd.conf /etc/dhcpcd.conf.backup
echo "Backup of /etc/dhcpcd.conf created at /etc/dhcpcd.conf.backup"

# Remove existing static IP configuration for Wi-Fi (assuming wlan0)
sed -i '/^interface wlan0/,/^$/d' /etc/dhcpcd.conf

# Append new static IP configuration for Wi-Fi
cat <<EOL >> /etc/dhcpcd.conf

interface wlan0
static ip_address=${STATIC_IP_WLAN}${SUBNET_WLAN}
static routers=${GATEWAY_WLAN}
static domain_name_servers=${DNS_WLAN}
EOL

echo "Static IP configuration added to /etc/dhcpcd.conf for wlan0"

# ------------------------------
# Configure Wi-Fi
# ------------------------------
WPA_SUPPLICANT_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"

echo "Updating Wi-Fi configuration in '$WPA_SUPPLICANT_CONF'..."
cat <<EOL >> "$WPA_SUPPLICANT_CONF"

network={
    ssid="$SSID"
    psk="$PSK"
    key_mgmt=WPA-PSK
    country=$COUNTRY
}
EOL

echo "Wi-Fi configuration updated in '$WPA_SUPPLICANT_CONF'"

# ------------------------------
# Apply Changes
# ------------------------------
echo "Restarting dhcpcd service..."
systemctl restart dhcpcd || error_exit "Failed to restart dhcpcd service."

echo "Updating hostname without reboot..."
hostname "$NEW_HOSTNAME"

echo "Configuration completed successfully."

# ------------------------------
# Reboot Prompt
# ------------------------------
read -p "Do you want to reboot now to apply all changes? (y/n): " REBOOT_CHOICE
if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
  echo "Rebooting now..."
  reboot
else
  echo "Please remember to reboot the system later to apply all changes."
fi
