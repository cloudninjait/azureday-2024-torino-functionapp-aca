@description('Name of Log Analytics Workspace')
param logAnalyticsName string

@description('Location for all resources.')
param location string = resourceGroup().location

param tags object

param retentionInDays int = 30

@description('SKU of Log Analytics Workspace')
@allowed([
  'PerNode'
  'Premium'
  'Standard'
  'Standalone'
  'Unlimited'
  'CapacityReservation'
  'PerGB2018'
])
param sku string = 'PerGB2018' //Pay-as-you-go

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output Id string = logAnalyticsWorkspace.id
