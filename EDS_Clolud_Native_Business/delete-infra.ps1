# delete-infra.ps1
param(
  [string]$resourceGroupName = "ag-digital-native-rg-dev"
)


#az group delete --name $resourceGroupName --yes --no-wait

$confirm = Read-Host "Are you sure you want to delete $resourceGroupName? (yes/no)"
if ($confirm -eq "yes") {
    Write-Host "Deleting resource group: $resourceGroupName ..."
    az group delete --name $resourceGroupName --yes
}


Write-Host "Resource group deletion initiated."


