param resourceName string // Resource Name of the target resource
param principalId string // ID of the User Assigned Identity or other principal

resource targetResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: resourceName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: targetResource
  name: guid(resourceName, principalId, 'RoleAssignment')
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalType: 'ServicePrincipal'
  }
}
