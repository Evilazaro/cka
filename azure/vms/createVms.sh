#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# # Check if all necessary parameters are provided
# if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ]; then
#     logMessage "Error: ResourceGroupName, AzureRegion, VnetName, KeyName, NsgName, and subnetName parameters are required."
#     logMessage "Usage: $0 <ResourceGroupName> <AzureRegion> <VnetName> <KeyName> <NsgName> <subnetName>"
#     exit 1
# fi

# Assign parameters to variables
resourceGroupName="$1"
azureRegion="$2"
vnetName="$3"
keyName="$4"
nsgName="$5"
subnetName="$6"
adminUsername="k8sadmin"
vmSize="Standard_B2s"
image="Ubuntu2204"
publicIpSku="Standard"
masterNodeName="$7"
workerNodeName="$8"

# Log the start of the script
logMessage "Starting the Azure VM creation script with the following settings:"
logMessage "Resource Group Name: $resourceGroupName"
logMessage "Azure Region: $azureRegion"
logMessage "VNet Name: $vnetName"
logMessage "Key Name: $keyName"
logMessage "NSG Name: $nsgName"

./security/createKeys.sh $keyName

# Create the first VM  for the Master Node
logMessage "Creating VM: $masterNodeName"
az vm create \
    --name $masterNodeName \
    --resource-group "$resourceGroupName" \
    --image "$image" \
    --vnet-name "$vnetName" \
    --subnet "$subnetName" \
    --admin-username "$adminUsername" \
    --ssh-key-value "./$keyName.pub" \
    --size "$vmSize" \
    --nsg "$nsgName" \
    --public-ip-sku "$publicIpSku" \
    --public-ip-address-dns-name "$masterNodeName"
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to create VM: $masterNodeName"
    exit 1
fi

# Create the second VM for the Worker Node
logMessage "Creating VM: $workerNodeName"
az vm create \
    --name $workerNodeName \
    --resource-group "$resourceGroupName" \
    --image "$image" \
    --vnet-name "$vnetName" \
    --subnet "$subnetName" \
    --admin-username "$adminUsername" \
    --ssh-key-value "./$keyName.pub" \
    --size "$vmSize" \
    --nsg "$nsgName" \
    --public-ip-sku "$publicIpSku"
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to create VM: $workerNodeName"
    exit 1
fi

logMessage "Azure VMs created successfully!"
