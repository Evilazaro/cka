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
az ssh vm --resource-group "$resourceGroupName" --vm-name "$vmName" --subscription "$subscriptionId"
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to login to VM: $vmName"
    exit 1
fi

logMessage "Successfully logged in to VM: $vmName"
