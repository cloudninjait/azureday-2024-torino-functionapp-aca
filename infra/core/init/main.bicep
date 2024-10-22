targetScope='subscription'

param appName string
param env string
param location string

param storageNames array = [
  'core'
  'services'
]

param tags object = {
  Application: appName
  Environment: env
  IaCProvider: 'Bicep'
}

resource createStorages 'Microsoft.Resources/resourceGroups@2024-03-01' = [for name in storageNames: {
  name: '${appName}-${env}-${name}'
  location: location
  tags: tags
}]
