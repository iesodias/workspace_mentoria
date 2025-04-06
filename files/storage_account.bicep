@description('Name of the Storage Account (3-24 chars, lowercase/numbers only)')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Location for the Storage Account')
@allowed([
  'eastus'
  'westus'
  'brazilsouth'
  'northeurope'
])
param location string = 'eastus'

@description('Type of Storage Account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Tags for organization and governance')
param tags object = {
  environment: 'dev'
  project: 'bicep-demo'
  owner: 'team-infra'
}

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  tags: tags
}

// Outputs with documentation
@description('Storage Account name')
output storageAccountName string = stg.name

@description('Storage Account ID')
output storageAccountId string = stg.id

@description('Primary Blob Endpoint')
output primaryBlobEndpoint string = stg.properties.primaryEndpoints.blob

@description('Tags applied')
output tags object = stg.tags
