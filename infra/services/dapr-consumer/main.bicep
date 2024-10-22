param env string
param appName string
param acrName string
param coreResourceGroup string
param imageTag string 
param cpu string
param mem string
param minReplica int
param maxReplica int
param scalerMessageCount string

var acrFullName = '${acrName}.azurecr.io'
var appId = 'daprconsumer'
var imageName = 'cloudninjadaprconsumer'
var topicName = 'test'

var serviceBusRuleName = 'RootManageSharedAccessKey'
var serviceBusAuthorizationSecret = 'busconnection'

var conventions = loadJsonContent('../../conventions.json')
var keyVaultName = '${appName}-${env}-${conventions.keyvault}'
var appInsightsName = '${appName}-${env}-${conventions.insights}'
var acaEnviromentName = '${appName}-${env}-${conventions.acaEnvironment}'
var managedIdentityName = '${appName}-${env}-${conventions.appIdentity}'
var serviceBusName = '${appName}-${env}-${conventions.serviceBus}'

param tags object = {
  Application: appName
  Environment: env
  IaCProvider: 'Bicep'
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(coreResourceGroup)
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
  scope: resourceGroup(coreResourceGroup)
}

// reference existing Service Bus
resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: serviceBusName
  scope: resourceGroup(coreResourceGroup)
}

// Create service bus authorisation rule for autoscaler
resource serviceBusAuthorisationRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-11-01' existing = {
  name: serviceBusRuleName
  parent: serviceBus
}

module acaApp '../../modules/aca/app.bicep' = {
  name: 'acaApp'
  params: {
    environment: env
    tags: tags
    secrets: [
      {
        name: serviceBusAuthorizationSecret
        value: serviceBusAuthorisationRule.listKeys().primaryConnectionString
      }
    ]
    ingressEnabled: false
    appId: appId
    acrName: acrName
    cpu: cpu
    memory: mem
    imageName: '${acrFullName}/${imageName}:${imageTag}'
    imageTag: imageTag
    environment_name: acaEnviromentName
    managedIdentityName: managedIdentityName
    enviromentVariables: [
      {
        name: 'ENVIRONMENT'
        value: env
      }
      {
        name: 'KeyVault__Vault'
        value: keyVault.properties.vaultUri
      }
      {
        name: 'KeyVault__ClientId'
        value: managedIdentity.id
      }
      {
        name: 'AppInsightsConnection'
        value: appInsights.properties.ConnectionString
      }
      {
        name: 'APP_PORT'
        value: '8080'
      }
    ]
    scale: {
      minReplicas: minReplica
      maxReplicas: maxReplica
      rules: [
        {
          name: 'topic-based-scaling'
          custom: {
            type: 'azure-servicebus'
            identity: 'user-assigned'
            metadata: {
              topicName: topicName
              subscriptionName: 'daprconsumer'
              messageCount: scalerMessageCount
            }
			      auth: [
                {
                  secretRef: serviceBusAuthorizationSecret
                  triggerParameter: 'connection'
                }
            ]
          }
        }
      ]
    }
  }
}

