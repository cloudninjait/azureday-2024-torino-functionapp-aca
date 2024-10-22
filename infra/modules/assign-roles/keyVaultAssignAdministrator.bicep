param resourceName string // Resource Name of the target resource
param principalId string // ID of the User Assigned Identity or other principal

resource targetResource 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: resourceName
}

//Key Vault Administrator ID
var roleId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'

resource keyVaultAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(targetResource.id, principalId, roleId) // Role assignment name must be a GUID
  scope: targetResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId:  principalId
    principalType: 'ServicePrincipal' // Or 'User' depending on your principal type
  }
}
