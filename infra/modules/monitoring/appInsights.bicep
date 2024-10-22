
param location string = resourceGroup().location
param appInsightsName string
param workspaceResourceId string
param tags object
param keyVaultName string = ''

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceResourceId
    Flow_Type: 'Bluefield'
  }
  tags: tags
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (! empty(keyVaultName)) {
  name: keyVaultName
}

resource appInsightssecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if (! empty(keyVaultName)) {
  parent: keyVault
  name: 'appInsightsConnection'
  tags: tags
  properties: {
    value: appInsights.properties.ConnectionString
  }
}
