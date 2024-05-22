#!/bin/bash

clear

# Constants
resourceGroupName="eShop-cKa-rg"
azureRegion="WestUS3"
kubernetesClusterName="eshop-cka-cluster"
vnetName="eshop-cka-vnet"
subnetName="eshop-cka-subnet"
keyName="eshop-cka.key"
nsgName="eshop-cka-nsg"
masterNodeName="kube-master-0"
workerNodeName="kube-worker-node-0"

checkError() {
    if [ $? -ne 0 ]; then
        logMessage "************************************************************************************************"
        logMessage "|                                      Oh,no!                                                  |"
        logMessage "|                              Something went wrong!                                           |"
        logMessage "************************************************************************************************"
        exit 1
    fi
}

# Function to log messages
logMessage() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if Azure Subscription Name is provided as a parameter
if [ -z "$1" ]; then
    logMessage "Error: Azure Subscription Name parameter is required."
    logMessage "Usage: $0 <azureSubscriptionName>"
    exit 1
fi

azureSubscriptionName="$1"

logMessage "************************************************************************************************"
logMessage "|                        Welcome to the eShop CKA Deployment Script!                            |"
logMessage "|     Please take a sit, and have fun! We are going to take care of everything for you          |"
logMessage "************************************************************************************************"


# Log the start of the script
logMessage "Starting the deployment script with the following settings:"
logMessage "Resource Group Name: $resourceGroupName"
logMessage "Azure Region: $azureRegion"
logMessage "Kubernetes Cluster Name: $kubernetesClusterName"
logMessage "Azure Subscription Name: $azureSubscriptionName"

# Placeholder for deployment commands

logMessage "Deployment script initialized successfully!"

# Log in to Azure
./security/login.sh $azureSubscriptionName

# Create Resource Group
logMessage "Creating Resource Group: $resourceGroupName in $azureRegion"
az group create --name "$resourceGroupName" --location "$azureRegion"
if [ $? -ne 0 ]; then
    logMessage "Error: Failed to create Resource Group: $resourceGroupName"
    exit 1
fi
logMessage "Resource Group created successfully!"

# Create Virtual Network
./networking/createVnet.sh $resourceGroupName $azureRegion $vnetName $subnetName $nsgName
checkError

# Create Master and Node K8s VMs
./vms/createVms.sh $resourceGroupName $azureRegion $vnetName $keyName $nsgName $subnetName $masterNodeName $workerNodeName
checkError

logMessage "************************************************************************************************"
logMessage "|                  I told you! We've taken care of everything for you.                          |"
logMessage "|                       Deployment script completed successfully!                               |"
logMessage "************************************************************************************************"