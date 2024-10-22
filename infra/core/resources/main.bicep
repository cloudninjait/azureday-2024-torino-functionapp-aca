param env string
param appName string
param location string = resourceGroup().location

var conventions = loadJsonContent('../../conventions.json')

var logAnalyticsWorkspaceName = '${appName}-${env}-${conventions.logAnalytics}'
var appInsightsName = '${appName}-${env}-${conventions.insights}'
var serviceBusNamespaceName = '${appName}-${env}-${conventions.serviceBus}'
var keyVaultName = '${appName}-${env}-${conventions.keyvault}'

param tags object = {
  Application: appName
  Environment: env
  IaCProvider: 'Bicep'
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
}

resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2022-11-01' = {
  parent: keyVault
  name: 'coreKey'
  tags: tags
  properties: {
    kty: 'RSA'
    keySize: 2048
  }
}

// Log Analytics Workspace
module logAnalyticsWorkspace '../../modules/monitoring/logAnalytics.bicep' = {
  name: logAnalyticsWorkspaceName
  params: {
    logAnalyticsName: logAnalyticsWorkspaceName
    tags: tags
  }
}

// Application Insights
module appInsights '../../modules/monitoring/appInsights.bicep' = {
  name: appInsightsName
  params: {
    appInsightsName: appInsightsName
    tags: tags
    workspaceResourceId: logAnalyticsWorkspace.outputs.Id
    keyVaultName: keyVaultName
  }
}

// Service Bus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {}
}

// Service Bus Authorization Rule
resource serviceBusAuthRule 'Microsoft.ServiceBus/namespaces/authorizationRules@2021-06-01-preview' = {
  parent: serviceBusNamespace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}


