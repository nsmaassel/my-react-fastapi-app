param location string = resourceGroup().location
param environmentName string
param containerRegistryName string
param customDomainName string = ''
param deployGitHubAction bool = true
param githubRepositoryUrl string = ''

// Create Azure Container Registry with Premium SKU for production
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

// Create Managed Identity for Container Apps
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${environmentName}-identity'
  location: location
}

// Create Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${environmentName}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
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

// Create Container Apps Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    zoneRedundant: true
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

// Create Backend Container App
resource backendApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'backend'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8000
        customDomains: !empty(customDomainName) ? [
          {
            name: 'api.${customDomainName}'
            bindingType: 'SniEnabled'
          }
        ] : []
      }
      registries: [
        {
          server: acr.properties.loginServer
          identity: managedIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'backend'
          image: '${acr.properties.loginServer}/backend:latest'
          env: [
            {
              name: 'ENVIRONMENT'
              value: 'production'
            }
            {
              name: 'WORKERS_COUNT'
              value: '4'
            }
            {
              name: 'TIMEOUT'
              value: '120'
            }
            {
              name: 'KEEP_ALIVE'
              value: '75'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsights.properties.ConnectionString
            }
          ]
          resources: {
            cpu: json('1.0')
            memory: '2Gi'
          }
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/api/health'
                port: 8000
              }
              initialDelaySeconds: 15
              periodSeconds: 30
            }
            {
              type: 'readiness'
              httpGet: {
                path: '/api/health'
                port: 8000
              }
              initialDelaySeconds: 5
              periodSeconds: 10
            }
          ]
        }
      ]
      scale: {
        minReplicas: 2
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

// Create Frontend Container App
resource frontendApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'frontend'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        customDomains: !empty(customDomainName) ? [
          {
            name: customDomainName
            bindingType: 'SniEnabled'
          }
        ] : []
      }
      registries: [
        {
          server: acr.properties.loginServer
          identity: managedIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'frontend'
          image: '${acr.properties.loginServer}/frontend:latest'
          env: [
            {
              name: 'NODE_ENV'
              value: 'production'
            }
            {
              name: 'VITE_API_URL'
              value: !empty(customDomainName) ? 'https://api.${customDomainName}' : 'https://${backendApp.properties.configuration.ingress.fqdn}'
            }
          ]
          resources: {
            cpu: json('1.0')
            memory: '2Gi'
          }
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/health'
                port: 80
              }
              initialDelaySeconds: 10
              periodSeconds: 30
            }
            {
              type: 'readiness'
              httpGet: {
                path: '/health'
                port: 80
              }
              initialDelaySeconds: 5
              periodSeconds: 10
            }
          ]
        }
      ]
      scale: {
        minReplicas: 2
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

// Add GitHub Action federated credentials if requested
resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = if (deployGitHubAction && !empty(githubRepositoryUrl)) {
  parent: managedIdentity
  name: 'github-action'
  properties: {
    audiences: ['api://AzureADTokenExchange']
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${replace(replace(githubRepositoryUrl, 'https://github.com/', ''), '//', '/')}:environment:production'
  }
}

output acrLoginServer string = acr.properties.loginServer
output frontendUrl string = !empty(customDomainName) ? 'https://${customDomainName}' : 'https://${frontendApp.properties.configuration.ingress.fqdn}'
output backendUrl string = !empty(customDomainName) ? 'https://api.${customDomainName}' : 'https://${backendApp.properties.configuration.ingress.fqdn}'
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output appInsightsConnectionString string = appInsights.properties.ConnectionString
