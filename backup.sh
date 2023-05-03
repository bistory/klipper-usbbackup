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

# Mount the selected partition
echo "Mounting /dev/${usb_drive}1 to /mnt..."
sudo mount "/dev/${usb_drive}1" /mnt

# Copy and compress files from the current user folder to a .tar.gz file on the selected USB drive
echo "Copying and compressing files to /dev/${usb_drive}..."
sudo tar -czpf /mnt/files-$(date +%Y-%m-%d).tar.gz --exclude=klipper --exclude=moonraker --exclude=mainsail --exclude=kiauh --exclude=crowsnest --exclude=KlipperScreen -C /home/$(whoami) .

# Unmount the USB drive
echo "Unmounting /dev/${usb_drive}1 from /mnt..."
sudo umount /mnt

echo "Done."
