// AZURE_DEPLOYMENT: Infrastructure as Code (Bicep)
// RESOURCE_TYPES: Container Registry, Container Apps, Application Insights
// DEPLOYMENT_TARGET: Azure Container Apps

param location string = resourceGroup().location
param environmentName string
param containerRegistryName string
param frontendAppName string = 'frontend'
param backendAppName string = 'backend'
param customDomainName string

// Create Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Create Container Apps Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
    }
    zoneRedundant: false
  }
}

// Create Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${environmentName}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Create Frontend Container App
resource frontendApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: frontendAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        customDomains: [
          {
            name: customDomainName
            bindingType: 'SniEnabled'
          }
        ]
      }
      registries: [
        {
          server: acr.properties.loginServer
          username: acr.listCredentials().username
          passwordSecretRef: 'registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: frontendAppName
          image: '${acr.properties.loginServer}/frontend:latest'
          env: [
            {
              name: 'NODE_ENV'
              value: 'production'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

// Create Backend Container App
resource backendApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: backendAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8000
        customDomains: [
          {
            name: 'api.${customDomainName}'
            bindingType: 'SniEnabled'
          }
        ]
      }
      registries: [
        {
          server: acr.properties.loginServer
          username: acr.listCredentials().username
          passwordSecretRef: 'registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: backendAppName
          image: '${acr.properties.loginServer}/backend:latest'
          env: [
            {
              name: 'ENVIRONMENT'
              value: 'production'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsights.properties.ConnectionString
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

output acrLoginServer string = acr.properties.loginServer
output frontendUrl string = 'https://${frontendApp.properties.configuration.ingress.fqdn}'
output backendUrl string = 'https://${backendApp.properties.configuration.ingress.fqdn}'
