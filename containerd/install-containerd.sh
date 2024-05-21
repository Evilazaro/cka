#!/bin/bash

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index
sudo apt-get update

# Install containerd
sudo apt-get install -y containerd.io

# Configure containerd and start the service
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd to ensure it uses the configuration file
sudo systemctl restart containerd
sudo systemctl enable containerd

# Verify the installation
containerd --version

echo "Containerd has been installed and configured successfully."

# Print instructions to verify containerd status
echo "Run 'sudo systemctl status containerd' to check the status of containerd service."
