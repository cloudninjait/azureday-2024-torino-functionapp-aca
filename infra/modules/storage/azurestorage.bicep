@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountType string = 'Standard_LRS'

param storageAccountName string
param blobContainerName string = ''
param servicePrincipal string = ''
param tags object

var location = resourceGroup().location

var normalizedAccountName = toLower(replace(storageAccountName, '-', ''))

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: normalizedAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
  properties: {
    allowBlobPublicAccess: true
    // Other properties for the storage account
  }
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: storageAccount
  name: 'default'
}

// Blob Container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = if (! empty(blobContainerName)) {
  parent: blobService
  name: blobContainerName
}

// Blob Data Contributor Role
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: storageAccount
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (! empty(servicePrincipal)) {
  name: guid(resourceGroup().id, contributorRoleDefinition.id)
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: servicePrincipal
    principalType: 'ServicePrincipal'
  }
}

output key string = storageAccount.listKeys().keys[0].value
