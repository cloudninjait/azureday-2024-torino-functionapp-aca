param env string
param appName string
param acrName string
param coreResourceGroup string
param busItems string
param imageTag string = 'latest'
param cpu string
param mem string
param cronSchedule string

var acrFullName = '${acrName}.azurecr.io'
var jobSchedule = cronSchedule
var reportingJobName = 'dapr-publisher'
var imageName = 'cloudninjadaprjob'

var conventions = loadJsonContent('../../conventions.json')

var appInsightsName = '${appName}-${env}-${conventions.insights}'
var acaEnviromentName = '${appName}-${env}-${conventions.acaEnvironment}'
var managedIdentityName = '${appName}-${env}-${conventions.appIdentity}'
var serviceBusNamespaceName = '${appName}-${env}-${conventions.serviceBus}'

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

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
  scope: resourceGroup(coreResourceGroup)
}

module acaJob '../../modules/aca/job.bicep' = {
  name: 'acaJob'
  params: {
    environment: env
    tags: tags
    acrName: acrName
    cpu: cpu
    memory: mem
    imageName: '${acrFullName}/${imageName}:${imageTag}'
    jobSchedule: jobSchedule
    reportingJobName: reportingJobName
    environment_name: acaEnviromentName
    managedIdentityName: managedIdentityName
    enviromentVariables: [
      {
        name: 'ENVIRONMENT'
        value: env
      }
      {
        name: 'AppInsightsConnection'
        value: appInsights.properties.ConnectionString
      }
      {
        name: 'Items'
        value: busItems
      }
      {
        name: 'ServiceBus__ConnectionString'
        value: serviceBusAuthRule.listKeys().primaryConnectionString
      }
    ]
  }
}
