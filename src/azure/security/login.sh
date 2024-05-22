#!/bin/bash

# Script to log in to Azure
# This script uses the Azure CLI to log in to an Azure account

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

# Function to handle errors
handle_error() {
    echo "An error occurred. Exiting..."
    exit 1
}

# Trap errors
trap handle_error ERR

# Check if Azure CLI is installed
echo "Checking if Azure CLI is installed..."
if ! command -v az &>/dev/null; then
    echo "Azure CLI not found. Please install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli and try again."
    exit 1
fi

# Log in to Azure
echo "Logging in to Azure..."
az login --use-device-code
az account set --subscription "$azureSubscriptionName"

# Check if login was successful
if [ $? -ne 0 ]; then
    echo "Login failed. Please check your credentials and try again."
    exit 1
fi

echo "Login successful!"
