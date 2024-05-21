#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if Resource Group Name, VM Name, and Subscription ID are provided as parameters
if [ -z "$1" ] || [ -z "$2" ] ; then
    logMessage "Error: ResourceGroupName, and VmName parameters are required."
    logMessage "Usage: $0 <ResourceGroupName> <VmName>"
    exit 1
fi

# Assign parameters to variables
resourceGroupName="$1"
vmName="$2"
keyName="$3"
k8sAdminName="$4"

# Get the current Azure Subscription ID
logMessage "Retrieving the current Azure Subscription ID"
subscriptionId=$(az account show --query id --output tsv)
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to retrieve the current Azure Subscription ID"
    exit 1
fi

logMessage "Current Azure Subscription ID: $subscriptionId"

# Log the start of the script
logMessage "Starting the Azure VM login script with the following settings:"
logMessage "Resource Group Name: $resourceGroupName"
logMessage "VM Name: $vmName"
logMessage "Subscription ID: $subscriptionId"

# Login to Azure VM
logMessage "Logging in to VM: $vmName in Resource Group: $resourceGroupName"

# Get the Public IP Address of the VM
logMessage "Retrieving the Public IP Address of the VM: $vmName"

vmPublicIpAddress=$(az vm list-ip-addresses --resource-group "$resourceGroupName" --name "$vmName" --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)
logMessage "Public IP Address of the VM: $vmPublicIpAddress"

if [ $? -ne 0 ]; then
    logMessage "Error: Failed to retrieve the Public IP Address of the VM: $vmName"
    exit 1
fi

logMessage "Public IP Address of the VM: $vmPublicIpAddress"

# Loging to the VM
logMessage "Logging in to VM: $vmName with the following settings:"
logMessage "COMANDO SSH: ssh ~/$keyName $k8sAdminName@$vmPublicIpAddress"
ssh -i ~/$keyName $k8sAdminName@$vmPublicIpAddress

if [ $? -ne 0 ]; then
    logMessage "Error: Failed to login to VM: $vmName"
    exit 1
fi

logMessage "Successfully logged in to VM: $vmName"
