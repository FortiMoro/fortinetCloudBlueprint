# fortinetCloudBlueprint - Deployment Instructions

## Any changes or modification of parameters should ONLY be performed in the 000-main.bicep file

## Obtaining the package - Commands to be run in Azure Cloud Shell (Azure CLI)

- git clone https://github.com/AJLab-GH/fortinetCloudBlueprint.git
- az login
- az account list
- az account set --subscription (subscriptionID) from previous command
- cd fortinetCloudBlueprint

## Create a resource group for your deployment
//  az group create --location (location) --name (resourceGroupName)                                                               //

## Deploy the templates
//  az deployment group create --name (deploymentName) --resource-group (resourceGroupName) --template-file 000-main.bicep         //

## Output resources values. i.e Public IPs, etc
//  az deployment group show  -g (resourceGroupName)   -n (deploymentName)  --query properties.outputs                             //
