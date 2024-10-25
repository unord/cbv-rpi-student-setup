# Raspberry Pi setup for U/NORD Carlsbergvej students

## Overview  
This script is designed by **U/NORD IT** and authored by **Gorm Reventlow**. It is intended for use by **U/NORD Carlsbergvej** students to streamline the setup of Wi-Fi connections and hostname configurations on Raspberry Pi devices.  
## Features  
- **Automated Hostname Setup**: Easily set a custom hostname for your Raspberry Pi. 
- **Static IP Configuration**: Configure a static IP address with predefined network settings. 
- **Mandatory Wi-Fi Configuration**: Ensure your Raspberry Pi connects to the designated Wi-Fi network. 
- **Configuration Validation**: Verifies all necessary parameters are correctly set before applying changes. 
- **Backup Creation**: Automatically backs up existing network configuration files for safety. 
## Prerequisites  
- A Raspberry Pi 4 running a compatible Linux distribution (e.g., Raspberry Pi OS). 
- `git` installed on your Raspberry Pi. 
- Sudo privileges to execute scripts with administrative rights.  

## Getting Started  
Follow these steps to clone the repository, set up permissions, configure your network settings, and run the script. 
### 1. Clone the Repository  
Open a terminal and clone directlyh down to the Raspberry Pi or a USB drive: 

```bash 
git clone https://github.com/unord/cbv-rpi-student-setup
```

### 2. Change File Permissions

Navigate to the cloned directory and make the script executable:

```bash
cd network-config 
chmod +x setup_static_ip.sh 
chmod 600 network_config.conf
```

- `setup_static_ip.sh`: Grants execute permissions to run the script.
- `network_config.conf`: Secures the configuration file by restricting read and write permissions to the owner only.

### 3. Modify the Configuration File

Edit the `network_config.conf` file to input your specific network settings:

```bash
nano network_config.conf
```
Update the following parameters as needed:

```bash
# ------------------------------ 
# Wi-Fi Configuration 
# ------------------------------ 
SSID=""                   # Your Wi-Fi SSID 
PSK=""             # Your Wi-Fi password 
COUNTRY="DK"                 # Country code (e.g., US, DK) 

# ------------------------------ 
# Ethernet Configuration 
# ------------------------------ 
SUBNET="/20"                 # Subnet mask in CIDR notation (e.g., /20) 
GATEWAY="10.126.193.xxx"       # Default gateway IP 
DNS="10.255.1.4 8.8.8.8 8.8.4.4"  # DNS servers separated by spaces
```

**Important:** Ensure all fields are correctly filled out to avoid configuration errors.

### 4. Run the Script

Execute the script with `sudo` to apply the network configurations:

```bash
sudo ./setup_static_ip.sh
```

Follow the on-screen prompts to:

1. Enter your desired hostname.
2. Specify the static IP address for your Raspberry Pi.
3. Confirm the application of changes and optionally reboot the system to apply configurations immediately.

## Troubleshooting

If you encounter any issues during the setup process, please reach out to our IT support:

📧 **Email**: helpdesk@unord.dk

Provide a detailed description of the problem, including any error messages received, to receive prompt assistance.

## Contributing

Contributions are welcome! If you have suggestions for improvements or encounter bugs, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
