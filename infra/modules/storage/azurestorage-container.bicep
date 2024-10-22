param storageAccountName string
param blobContainerName string
param publicAccessLevel string = 'None'

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' existing = {
  parent: storageAccount
  name: 'default'
}

// Blob Container
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  parent: blobService
  name: blobContainerName
  properties: {
    publicAccess: publicAccessLevel // or 'Container' for full container access
  }
}
