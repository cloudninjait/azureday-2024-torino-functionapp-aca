param env string
param appName string
param acrName string
param coreResourceGroup string
param imageTag string 
param cpu string
param mem string
param minReplica int
param maxReplica int

var acrFullName = '${acrName}.azurecr.io'
var appId = 'daprstatehello'
var imageName = 'cloudninjadaprhello'

var conventions = loadJsonContent('../../conventions.json')
var keyVaultName = '${appName}-${env}-${conventions.keyvault}'
var appInsightsName = '${appName}-${env}-${conventions.insights}'
var acaEnviromentName = '${appName}-${env}-${conventions.acaEnvironment}'
var managedIdentityName = '${appName}-${env}-${conventions.appIdentity}'

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

module acaApp '../../modules/aca/app.bicep' = {
  name: 'acaApp'
  params: {
    environment: env
    tags: tags
    secrets: []
    scale: {
      minReplicas: minReplica
      maxReplicas: maxReplica
    }
    ingressEnabled: true
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
  }
}

