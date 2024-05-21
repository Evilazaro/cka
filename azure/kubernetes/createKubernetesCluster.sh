#!/bin/bash

#!/bin/bash

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Assign parameters to variables
resourceGroupName="eShop-cKa-rg"
masterNodeName="kube-master-0"


# Log the start of the script
logMessage "Starting the Azure VM login script with the following settings:"
logMessage "Resource Group Name: $resourceGroupName"
logMessage "VM Name: $masterNodeName"

# Login to Azure VM
logMessage "Logging in to VM: $masterNodeName in Resource Group: $resourceGroupName"
./connectToVM.sh $resourceGroupName $masterNodeName