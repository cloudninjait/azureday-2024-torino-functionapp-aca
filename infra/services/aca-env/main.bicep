param env string
param appName string
param location string = resourceGroup().location

param acrName string
param acrResourceGroup string
param coreResourceGroup string

var conventions = loadJsonContent('../../conventions.json')
var logAnalyticsWorkspaceName = '${appName}-${env}-${conventions.logAnalytics}'
var appInsightsName = '${appName}-${env}-${conventions.insights}'
var serviceBusNamespaceName = '${appName}-${env}-${conventions.serviceBus}'
var keyVaultName = '${appName}-${env}-${conventions.keyvault}'
var acaEnviromentName = '${appName}-${env}-${conventions.acaEnvironment}'
var managedIdentityName = '${appName}-${env}-${conventions.appIdentity}'
var storageAccountName = toLower(replace('${appName}${env}aca${conventions.storage}', '-', ''))

var blobContainerName = 'state'

param tags object = {
  Application: appName
  Environment: env
  IaCProvider: 'Bicep'
}

// Service Bus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
  scope: resourceGroup(coreResourceGroup)
}

// Service Bus Authorization Rule
resource serviceBusAuthRule 'Microsoft.ServiceBus/namespaces/authorizationRules@2021-06-01-preview' existing = {
  parent: serviceBusNamespace
  name: 'RootManageSharedAccessKey'
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(coreResourceGroup)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
  scope: resourceGroup(coreResourceGroup)
}

// Managed Identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: managedIdentityName
  location: location
  tags: tags
}

//Azure Storage Account with Managed Identity access
module azurestorage '../../modules/storage/azurestorage.bicep' = {
  name: 'azurestorage'
  params: {
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
    servicePrincipal: managedIdentity.properties.principalId
    tags: tags
  }
}

// Managed Environment
resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: acaEnviromentName
  location: location
  tags: tags
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// Dapr state store component
resource daprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: 'statestore'
  parent: environment
  properties: {
    componentType: 'state.azure.blobstorage'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '5s'
    metadata: [
      {
        name: 'accountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: blobContainerName
      }
      {
        name: 'azureClientId'
        value: managedIdentity.properties.clientId
      }
    ]
  }
}

// Dapr pubsub component for Azure Service Bus
resource daprPubSubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: 'pubsub'
  parent: environment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '5s'
    metadata: [
      {
        name: 'connectionString'
        value: serviceBusAuthRule.listKeys().primaryConnectionString
      }
      {
        name: 'maxActiveMessages'
        value: '100'
      }
      {
        name: 'maxConcurrentHandlers'
        value: '16'
      }
    ]
  }
}

module acrAssignment '../../modules/assign-roles/acrAssignPull.bicep' = {
  name: 'acrAssignment'
  scope: resourceGroup(acrResourceGroup)
  params: {
    resourceName: acrName
    principalId: managedIdentity.properties.principalId
  }
}

module keyVaultAssignment '../../modules/assign-roles/keyVaultAssignAdministrator.bicep' = {
  name: 'keyVaultAssignment'
  scope: resourceGroup(coreResourceGroup)
  params: {
    resourceName: keyVaultName
    principalId: managedIdentity.properties.principalId
  }
}
