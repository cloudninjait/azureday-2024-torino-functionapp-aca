//Existing ACA Enviroment
param environment_name string

param environment string

param appId string

//ACA Managed Identity
param managedIdentityName string

//Azure Container Registry which hosts the Image of the Job
param acrName string
param imageName string
param imageTag string

//Container Resource Requirements
param cpu string
param memory string

//Job information in terms of naming, cron schedule and set of variabiles that should be assigned for the specific environment
param enviromentVariables array

param tags object

param ingressEnabled bool

param scale object

param secrets array

var acrFullName = '${acrName}.azurecr.io'
var location = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource acaEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: environment_name
}

resource coreApi 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'app-${appId}-${environment}'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}' : {}
    }
  }
  properties: {
    managedEnvironmentId: acaEnvironment.id
    configuration: {
      activeRevisionsMode: 'multiple'
      registries: [
        {
          server: acrFullName
          identity: managedIdentity.id
        }
      ]
      ingress: {
        external: ingressEnabled
        targetPort: 8080
      }
      dapr: {
        enabled: true
        appId: appId
        appProtocol: 'http'
        appPort: 8080
      }
      secrets: secrets
    }
    template: {
      revisionSuffix: imageTag
      containers: [
        {
          image: imageName
          name: appId
          env: enviromentVariables
          resources: {
            cpu: json(cpu)
            memory: '${memory}Gi'
          }
        }
      ]
      scale: scale
    }
  }
}
