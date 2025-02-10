# Creating Your Own "Deploy to Azure" Button: A Tutorial

## Prerequisites
- Azure CLI installed
- Basic understanding of Azure resources
- A GitHub repository
- Visual Studio Code with Bicep extension (recommended)

## Step 1: Start with Infrastructure as Code

### Create Your First Bicep File
```bicep
// main.bicep
param location string = resourceGroup().location
param projectName string

// Define more parameters you need
```

### Key Concepts to Learn:
1. Parameters vs Variables
2. Resource Dependencies
3. Outputs for later use

## Step 2: Building Your Resource Set

Start small and expand. Example progression:

1. **Basic Setup**
   ```bicep
   // Begin with essential resources
   resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
     name: '${projectName}-plan'
     location: location
     // ...
   }
   ```

2. **Add More Resources**
   - Add one resource at a time
   - Test between additions
   - Document your changes

## Step 3: Converting to ARM Template

1. Use Azure CLI:
   ```bash
   az bicep build --file main.bicep --outfile azuredeploy.json
   ```

2. Validate the template:
   ```bash
   az deployment group validate \
     --resource-group test-rg \
     --template-file azuredeploy.json
   ```

## Step 4: Creating the Deploy Button

1. Host your template in a public GitHub repo
2. Create the button URL:
   ```
   https://portal.azure.com/#create/Microsoft.Template/uri/[ENCODED_URL_TO_YOUR_TEMPLATE]
   ```

## Step 5: Testing and Iteration

### Local Testing Prerequisites
- Docker and Docker Compose installed
- Azure CLI installed and configured
- Git installed

### Local Testing Steps
1. **Test Local Infrastructure**
   ```bash
   # On Windows
   scripts/test-deployment.bat up
   
   # On Unix/Linux
   chmod +x scripts/test-deployment.sh
   ./scripts/test-deployment.sh up
   ```
   This will:
   - Build and start containers locally
   - Run health checks
   - Execute e2e tests
   - Provide local URLs for testing

2. **Verify Local Deployment**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000/api/health
   - API Documentation: http://localhost:8000/api/docs

3. **Cleanup After Testing**
   ```bash
   # On Windows
   scripts/test-deployment.bat clean
   
   # On Unix/Linux
   ./scripts/test-deployment.sh clean
   ```

### Azure Test Deployment
After successful local testing:

1. **Test Infrastructure Deployment**
   ```bash
   cd infrastructure
   az bicep build --file main.test.bicep --outfile azuredeploy.test.json
   az deployment group validate \
     --resource-group test-rg \
     --template-file azuredeploy.test.json
   ```

2. **Deploy Test Environment**
   ```bash
   ./deploy-test.sh -d -n myapp -e test -l eastus
   ```

3. **Cleanup Test Resources**
   ```bash
   ./deploy-test.sh -c -n myapp -e test
   ```

## Common Patterns

### Resource Naming
```bicep
param projectName string
param environment string

var resourceNames = {
  registry: '${projectName}registry${environment}'
  webapp: '${projectName}-web-${environment}'
}
```

### Dynamic Configuration
```bicep
param skuName string = 'Basic'
param isProd bool = false

var skuTier = isProd ? 'Premium' : 'Basic'
```

## Examples

### Basic Web App
[Link to example in repo]

### Containerized Application
[Link to example in repo]

### Microservices Architecture
[Link to example in repo]

## Best Practices Checklist

- [ ] Use descriptive parameter names
- [ ] Implement proper tagging
- [ ] Set up monitoring
- [ ] Configure backups
- [ ] Implement security best practices
- [ ] Add proper documentation

## Exercise: Create Your First Template

1. Clone the starter template
2. Add a simple resource
3. Build and test
4. Create deploy button
5. Share with team

## Next Steps

1. Learn about advanced Bicep features
2. Implement CI/CD with templates
3. Explore managed identities
4. Study cost optimization

## Troubleshooting Guide

### Common Issues and Solutions

1. **Resource Names**
   - Problem: Naming conflicts
   - Solution: Use unique naming patterns

2. **Dependencies**
   - Problem: Resources deploying out of order
   - Solution: Use proper dependency chains

3. **Permissions**
   - Problem: Insufficient permissions
   - Solution: Check RBAC requirements

## Advanced Topics

1. **Conditional Deployment**
   ```bicep
   resource backup 'Microsoft.Storage/storageAccounts@2021-04-01' = if (isProd) {
     // Production backup storage
   }
   ```

2. **Loops and Arrays**
   ```bicep
   param locations array
   resource multiRegion 'Microsoft.Web/sites@2021-02-01' = [for location in locations: {
     // Deploy to multiple regions
   }]
   ```

3. **Modules**
   ```bicep
   module networking 'networking.bicep' = {
     name: 'networkingDeployment'
     params: {
       // Module parameters
     }
   }
   ```

## Resources

### Official Documentation
- Azure Resource Manager
- Bicep Language
- Azure CLI

### Community Resources
- Azure Discord
- Stack Overflow tags
- GitHub discussions

### Tools
- VS Code extensions
- ARM Template Viewer
- Bicep Playground