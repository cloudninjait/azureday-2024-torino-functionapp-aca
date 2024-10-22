//Existing ACA Enviroment
param environment_name string

param environment string

//ACA Managed Identity
param managedIdentityName string

//Azure Container Registry which hosts the Image of the Job
param acrName string
param imageName string

//Container Resource Requirements
param cpu string
param memory string

//Job information in terms of naming, cron schedule and set of variabiles that should be assigned for the specific environment
param reportingJobName string
param jobSchedule string
param enviromentVariables array

param tags object

var acrFullName = '${acrName}.azurecr.io'
var location = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource acaEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: environment_name
}

resource reportingjob 'Microsoft.App/jobs@2024-03-01' = {
  name: 'job-${reportingJobName}-${environment}'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}' : {}
    }
  }
  properties: {
    environmentId: acaEnvironment.id
    workloadProfileName: null
    configuration: {
      triggerType: 'Schedule'
      replicaTimeout: 1800
      replicaRetryLimit: 0
      manualTriggerConfig: null
      scheduleTriggerConfig: {
        replicaCompletionCount: 1
        cronExpression: jobSchedule
        parallelism: 1
      }
      eventTriggerConfig: null
      registries: [
        {
          server: acrFullName
          identity: managedIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          image: imageName
          name: reportingJobName
          env: enviromentVariables
          resources: {
            cpu: json(cpu)
            memory: '${memory}Gi'
          }
        }
      ]
    }
  }
}
