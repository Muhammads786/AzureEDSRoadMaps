# --------------------------------------------------------------------------------
# Phase 2: Azure Data Platform Setup Script
# Including Networking, Storage, Security, and Governance
# --------------------------------------------------------------------------------

# Define Variables
$resourceGroupName = "ag-digital-native-rg-dev"
$location = "eastus"
$storageAccountName = "agstoragedldev"
$keyVaultName = "agdatakeyvaultdev"
$purviewAccountName = "ag-purviewaccount-dev"
$vnetName = "ag-data-vnet-dev"
$subnetNameStorage = "storage-subnet-dev"
$subnetNameKeyVault = "ag-keyvault-subnet-dev"
$nsgName = "ag-data-nsg-dev"
$addressPrefix = "10.0.0.0/16"
$subnetPrefixStorage = "10.0.1.0/24"
$subnetPrefixKeyVault = "10.0.2.0/24"
$containers = @("raw", "curated", "analytics")

# Create Resource Group
az group create --name $resourceGroupName --location $location

# Create Virtual Network (VNET) with Address Space
az network vnet create `
  --resource-group $resourceGroupName `
  --name $vnetName `
  --address-prefix $addressPrefix `
  --subnet-name $subnetNameStorage `
  --subnet-prefix $subnetPrefixStorage

# Add Additional Subnet for Key Vault
az network vnet subnet create `
  --resource-group $resourceGroupName `
  --vnet-name $vnetName `
  --name $subnetNameKeyVault `
  --address-prefix $subnetPrefixKeyVault

# Create Network Security Group (NSG) to Protect Subnets
az network nsg create `
  --resource-group $resourceGroupName `
  --name $nsgName

# Associate NSG to Both Subnets
az network vnet subnet update `
  --vnet-name $vnetName `
  --name $subnetNameStorage `
  --resource-group $resourceGroupName `
  --network-security-group $nsgName

az network vnet subnet update `
  --vnet-name $vnetName `
  --name $subnetNameKeyVault `
  --resource-group $resourceGroupName `
  --network-security-group $nsgName

# Create Storage Account with Hierarchical Namespace (Data Lake Gen2)
az storage account create `
  --name $storageAccountName `
  --resource-group $resourceGroupName `
  --location $location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --hierarchical-namespace true `
  

# Create Private Endpoint for Storage Blob Access
az network private-endpoint create `
  --resource-group $resourceGroupName `
  --name "pe-storage" `
  --vnet-name $vnetName `
  --subnet $subnetNameStorage `
  --private-connection-resource-id $(az storage account show --name $storageAccountName --resource-group $resourceGroupName --query id --output tsv) `
  --group-id "blob" `
  --connection-name "storage-connection"

# Create Azure Key Vault for Secrets and Key Management
az keyvault create `
  --name $keyVaultName `
  --resource-group $resourceGroupName `
  --location $location `
  --enable-purge-protection true
  #--enable-soft-delete true `

# Create Private Endpoint for Key Vault
az network private-endpoint create `
  --resource-group $resourceGroupName `
  --name "pe-keyvault" `
  --vnet-name $vnetName `
  --subnet $subnetNameKeyVault `
  --private-connection-resource-id $(az keyvault show --name $keyVaultName --resource-group $resourceGroupName --query id --output tsv) `
  --group-id "vault" `
  --connection-name "keyvault-connection"

# Create Azure Purview Account for Metadata and Governance
<#
az purview account create `
  --name $purviewAccountName `
  --resource-group $resourceGroupName `
  --location $location `
  --sku Standard `
  --managed-resource-group "${purviewAccountName}-managed-rg"
#>


# Create Containers in Storage Account for Different Data Zones
foreach ($container in $containers) {
    az storage container create `
        --name $container `
        --account-name $storageAccountName
}

# Optional: Upload Sample Dataset (e.g., Customers CSV) to Raw Zone
az storage blob upload `
  --account-name $storageAccountName `
  --container-name raw `
  --file "./departuredelays.csv" `
  --name departuredelays.csv
