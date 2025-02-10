param containerRegistryName string
param location string = resourceGroup().location

// Create Azure Container Registry with Basic SKU for testing
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Output the login server for use in scripts
output loginServer string = acr.properties.loginServer
output name string = acr.name
