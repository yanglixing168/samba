#!/bin/bash

# Check if the script is run as root or with sudo privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo privileges."
    exit 1
fi

# Variables for your shared folder and user settings
shared_folder_name="myshare"
shared_folder_path="/path/to/shared_folder"
samba_user="sambauser"
samba_password="yourpassword"

# Install Samba if not already installed
if ! rpm -q samba; then
    yum install samba -y
fi

# Create the shared folder if it doesn't exist
if [ ! -d "$shared_folder_path" ]; then
    mkdir -p "$shared_folder_path"
fi

# Configure Samba
cat <<EOL >> /etc/samba/smb.conf
[$shared_folder_name]
   path = $shared_folder_path
   valid users = $samba_user
   read only = no
   create mask = 0660
   directory mask = 0770
EOL

# Set the Samba password for the user
(echo "$samba_password"; echo "$samba_password") | smbpasswd -s -a "$samba_user"

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
