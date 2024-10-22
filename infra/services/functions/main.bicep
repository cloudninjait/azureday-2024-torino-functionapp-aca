@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'

param env string
param appName string
param coreResourceGroup string

var conventions = loadJsonContent('../../conventions.json')
var functionAppName = '${appName}-${env}-${conventions.functionApp}'
var hostingPlanName = '${appName}-${env}-${conventions.appPlan}'
var applicationInsightName = '${appName}-${env}-${conventions.insights}'
var storageAccountName = '${appName}${env}func${conventions.storage}'
var serviceBusNamespaceName = '${appName}-${env}-${conventions.serviceBus}'

var location = resourceGroup().location

param tags object = {
  Application: appName
  Environment: env
  IaCProvider: 'Bicep'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightName
  scope: resourceGroup(coreResourceGroup)
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

module stgModule '../../modules/storage/azurestorage.bicep' = {
  name: storageAccountName
  params: {
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
    tags: tags
  }
}

module hostingModule '../../modules/web/hostingPlanModules.bicep' = {
  name: hostingPlanName
  params: {
    location: location
    hostingPlanName: hostingPlanName
    tags: tags
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    stgModule
    hostingModule
  ]
  properties: {
    serverFarmId: hostingModule.outputs.Id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${stgModule.outputs.key}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${stgModule.outputs.key}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'ServiceBusConnectionString'
          value: serviceBusAuthRule.listKeys().primaryConnectionString
        }
        {
          name: 'ServiceBusTopicName'
          value: 'test'
        }
        {
          name: 'ServiceBusSubscriptionNameFunctionApp'
          value: 'functionappconsumer'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
  tags: tags
}


