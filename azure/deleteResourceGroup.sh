#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if Resource Group Name is provided as a parameter
if [ -z "$1" ]; then
    logMessage "Error: ResourceGroupName parameter is required."
    logMessage "Usage: $0 <ResourceGroupName>"
    exit 1
fi

# Assign parameter to variable
resourceGroupName="$1"

# Log the start of the script
logMessage "Starting the Azure environment cleanup script for Resource Group: $resourceGroupName"

# Delete the Resource Group and all its resources
logMessage "Deleting Resource Group: $resourceGroupName and all its resources"
az group delete --name "$resourceGroupName" --yes --no-wait
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to delete Resource Group: $resourceGroupName"
    exit 1
fi

logMessage "Resource Group: $resourceGroupName deletion initiated successfully!"
logMessage "Azure environment cleanup script completed!"
