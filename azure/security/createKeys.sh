#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if the key name parameter is provided
if [ -z "$1" ]; then
    logMessage "Error: Key name parameter is required."
    logMessage "Usage: $0 <KeyName>"
    exit 1
fi

# Assign parameter to variable
keyName="$1"

# Log the start of the script
logMessage "Starting the SSH key generation script with the following settings:"
logMessage "Key Name: $keyName"

rm -f ~/$keyName

# Generate SSH key pair
logMessage "Generating SSH key pair..."
ssh-keygen -t rsa -b 2048 -f "$keyName" -N ''
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to generate SSH key pair."
    exit 1
fi

# Copy the private key to the home directory
logMessage "Copying the private key to the home directory..."
cp "$keyName" ~/
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to copy the private key to the home directory."
    exit 1
fi

# Set permissions for the private key
logMessage "Setting permissions for the private key..."
chmod 400 ~/"$keyName"
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to set permissions for the private key."
    exit 1
fi

logMessage "SSH key pair generated and configured successfully!"
