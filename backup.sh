#!/bin/bash

# Check if there are any USB drives available
if [[ ! $(lsblk -o NAME,SIZE | grep -e "^sd.*") ]]; then
    echo "No USB drives detected."
    exit 1
fi

# List available USB drives
echo "Available USB drives:"
lsblk -o NAME,SIZE,MOUNTPOINT | grep -e "^sd.*" | nl -nln

# Prompt the user to choose a drive
read -p "Please enter the number of the USB drive you wish to use: " drive_number

# Get the device name of the selected drive
usb_drive=$(lsblk -o NAME | grep -e "^sd.*" | sed "${drive_number}q;d")

# Check if the selected drive is mounted
if [[ ! $(lsblk -o MOUNTPOINT "/dev/$usb_drive" | tail -1) == "" ]]; then
    echo "Selected USB drive is already mounted, please unmount it and try again."
    exit 1
fi

# Get the first partition of the selected drive
usb_partition=$(ls "/dev/${usb_drive}"* | grep -E "^/dev/${usb_drive}[[:digit:]]$" | head -1)

# Mount the selected partition
echo "Mounting ${usb_partition}..."
sudo mount "${usb_partition}" /mnt

# Copy and compress files from the current user folder to a .tag.xz file on the selected USB drive
echo "Copying and compressing files to ${usb_partition}..."
sudo tar -cpzf /mnt/backup-$(date +%Y-%m-%d).tar.gz /home/$USER/printer_data/config /home/$USER/printer_data/database /home/$USER/printer_data/gcodes

# Unmount the USB drive
echo "Unmounting ${usb_partition}..."
sudo umount /mnt

echo "Done."
