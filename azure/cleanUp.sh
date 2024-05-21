#!/bin/bash

clear

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Assign parameters to an array
resourceGroupNames=("eShop-cKa-rg" "NetworkWatcherRG" "DefaultResourceGroup-WUS2")

# Log the start of the script
logMessage "Starting the Azure environment cleanup script with the following settings:"

# Check if deleteResourceGroup.sh script is available
if [ ! -f deleteResourceGroup.sh ]; then
    logMessage "Error: deleteResourceGroup.sh script not found."
fi

# Loop through each resource group name and execute the deleteResourceGroup.sh script
for resourceGroupName in "${resourceGroupNames[@]}"; do
    ./deleteResourceGroup.sh "$resourceGroupName"
    if [ $? -ne 0 ]; then
        logMessage "Error: Failed to execute deleteResourceGroup.sh script for Resource Group: $resourceGroupName"
    fi
done

# Remove all files in the current directory
cd ~
find . -maxdepth 1 -type f -exec rm -f {} \;

logMessage "Azure environment cleanup completed successfully for all specified resource groups!"
