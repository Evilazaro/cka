#!/bin/bash

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

# Assign parameters to variables
resourceGroupName="eShop-cKa-rg"
azureRegion="WestUS3"
kubernetesClusterName="eshop-cka-cluster"
vnetName="eshop-cka-vnet"
subnetName="eshop-cka-subnet"
keyName="eshop-cka.key"
nsgName="eshop-cka-nsg"
masterNodeName="kube-master-0"
workerNodeName="kube-worker-node-0"
k8sAdminName="k8sadmin"

logMessage "************************************************************************************************"
logMessage "|                     Let's prepare and deploy your Kubernetes Cluster!                         |"
logMessage "|             Please have a sit! We are going to take care of everything for you                |"
logMessage "************************************************************************************************"


# Log the start of the script
logMessage "Starting the Azure VM login script with the following settings:"
logMessage "Resource Group Name: $resourceGroupName"
logMessage "VM Name: $masterNodeName"

sudo ./installKubeAdmAndContainerdTools.sh $masterNodeName
checkError

logMessage "************************************************************************************************"
logMessage "|                                     I told you!                                               |"
logMessage "|                       Deployment script completed successfully!                               |"
logMessage "************************************************************************************************"
