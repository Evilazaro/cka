#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if Resource Group Name and NSG Name are provided as parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    logMessage "Error: Both ResourceGroupName and NsgName parameters are required."
    logMessage "Usage: $0 <ResourceGroupName> <NsgName>"
    exit 1
fi

# Assign parameters to variables
resourceGroupName="$1"
nsgName="$2"

# Log the start of the script
logMessage "Starting the Azure Network Security Group (NSG) creation script with the following settings:"
logMessage "Resource Group Name: $resourceGroupName"
logMessage "NSG Name: $nsgName"

# Create Network Security Group (NSG)
logMessage "Creating Network Security Group: $nsgName in Resource Group: $resourceGroupName"
az network nsg create --resource-group "$resourceGroupName" --name "$nsgName"
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to create Network Security Group: $nsgName"
    exit 1
fi

# Create NSG Rule for SSH
logMessage "Creating NSG Rule for SSH (port 22) in NSG: $nsgName"
az network nsg rule create --resource-group "$resourceGroupName" --nsg-name "$nsgName" --name kubeadmssh --protocol tcp --priority 1000 --destination-port-range 22 --access allow
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to create NSG Rule for SSH"
    exit 1
fi

# Create NSG Rule for Kubernetes API Server
logMessage "Creating NSG Rule for Kubernetes API Server (port 6443) in NSG: $nsgName"
az network nsg rule create --resource-group "$resourceGroupName" --nsg-name "$nsgName" --name kubeadmWeb --protocol tcp --priority 1001 --destination-port-range 6443 --access allow
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to create NSG Rule for Kubernetes API Server"
    exit 1
fi

logMessage "Azure Network Security Group and rules created successfully!"
