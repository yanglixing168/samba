#!/bin/bash

# Check if the script is run as root or with sudo privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo privileges."
    exit 1
fi

# Variables for your shared folder and user settings
share_folder_name="share"
shared_folder_path="/home/share"
samba_user="user0"
samba_password="user0"

# Install Samba if not already installed
if ! rpm -q samba; then
    yum install samba samba-client -y
fi



# Create the shared folder if it doesn't exist
if [ ! -d "/home/share" ]; then
    mkdir -p "/home/share"
fi

# Configure Samba
cat <<EOL >> /etc/samba/smb.conf
[share]
   path = /home/share
   browseable = yes
   writable = yes
   public = yes
EOL

# Set the Samba password for the user
(echo "user0"; echo "user0") | smbpasswd -s -a "user0"

# Restart Samba to apply the changes
systemctl restart smb

# Enable and start the Samba service at boot
systemctl enable smb
systemctl start smb

# Allow Samba traffic through the firewall
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload

# Print a message indicating the configuration is complete
echo "Samba has been configured. Shared folder: $shared_folder_path, User: $samba_user"

# Install dos2unix if not already installed
if ! rmp -q dos2unix; then
    yum install dos2unix -y
fi

#convert samba.sh
dos2unix samba.sh



