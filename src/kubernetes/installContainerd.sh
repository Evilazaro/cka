#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Update the package index
logMessage "Updating package index..."
sudo apt-get update && sudo apt-get upgrade -y

# Add Docker’s official GPG key
logMessage "Adding Docker’s official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker stable repository
logMessage "Setting up the Docker stable repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index again
logMessage "Updating package index again..."
sudo apt-get update && sudo apt-get upgrade -y

# Install containerd
logMessage "Installing containerd..."
sudo apt-get install -y containerd.io

# Create the default config.toml configuration file
logMessage "Creating the default containerd configuration file..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
logMessage "Restarting containerd..."
sudo systemctl restart containerd

# Enable containerd to start on boot
logMessage "Enabling containerd to start on boot..."
sudo systemctl enable containerd

logMessage "containerd installation completed successfully!"
