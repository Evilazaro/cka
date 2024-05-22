#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if Resource Group Name and Azure Region are provided as parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    logMessage "Error: Both ResourceGroupName and AzureRegion parameters are required."
    logMessage "Usage: $0 <ResourceGroupName> <AzureRegion>"
    exit 1
fi

# Assign parameters to variables
resourceGroupName="$1"
azureRegion="$2"
vnetName="$3"
addressPrefix="10.0.0.0/16"
subnetName="$4"
nsgName="$5"

# Create NSG Rules
./networking/createNsgrules.sh $resourceGroupName $nsgName

# Log the start of the script
logMessage "Starting the Azure Virtual Network creation script with the following settings:"
logMessage "Resource Group Name: $resourceGroupName"
logMessage "Azure Region: $azureRegion"
logMessage "Virtual Network Name: $vnetName"
logMessage "Address Prefix: $addressPrefix"

# Create Virtual Network
logMessage "Creating Virtual Network: $vnetName in Resource Group: $resourceGroupName"
az network vnet create --resource-group "$resourceGroupName" --name "$vnetName" --address-prefix "$addressPrefix" --location "$azureRegion" --subnet-name "$subnetName" --subnet-prefix "$addressPrefix"
az network vnet subnet update --name "$subnetName" --vnet-name "$vnetName" --resource-group "$resourceGroupName" --network-security-group "$nsgName"
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to create Virtual Network: $vnetName"
    exit 1
fi

logMessage "Azure Virtual Network created successfully!"
