param hostingPlanName string
param location string
param tags object

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
  tags: tags
}

output Id string = hostingPlan.id
