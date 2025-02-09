# Azure Deployment Guide

<!-- AZURE_DEPLOYMENT: Configuration and setup guide -->
<!-- CICD_DEPLOYMENT_CONFIG: Azure Container Apps with GitHub Actions -->
<!-- DEPLOYMENT_TYPE: Container Apps -->
<!-- PIPELINE_TYPE: GitHub Actions -->

This document outlines the Azure setup for our trunk-based development workflow.

## Required Azure Resources

1. **Azure Container Registry (ACR)**
   - Used to store our Docker images
   - Premium SKU recommended for better performance and features

2. **Azure Container Apps**
   - For hosting both frontend and backend services
   - Supports scaling and managed HTTPS

3. **Azure DNS Zone** (Optional)
   - For custom domain management

## Required GitHub Secrets

Add these secrets to your GitHub repository:

```plaintext
AZURE_CREDENTIALS              # Service principal credentials for Azure authentication
REGISTRY_LOGIN_SERVER         # ACR login server URL (e.g., myregistry.azurecr.io)
REGISTRY_USERNAME            # ACR username
REGISTRY_PASSWORD           # ACR password
REGISTRY_NAME              # ACR registry name
```

## Required GitHub Variables

Add these variables to your GitHub repository:

```plaintext
AZURE_RESOURCE_GROUP        # Resource group containing your Azure resources
AZURE_APP_HOSTNAME         # Base hostname for your application
AZURE_LOCATION            # Azure region for deployments
```

## Initial Azure Setup

1. **Create Resource Group**
   ```bash
   az group create --name myapp-rg --location eastus
   ```

2. **Create Container Registry**
   ```bash
   az acr create --resource-group myapp-rg \
     --name myappregistry \
     --sku Premium \
     --admin-enabled true
   ```

3. **Create Container Apps Environment**
   ```bash
   az containerapp env create \
     --name myapp-env \
     --resource-group myapp-rg \
     --location eastus
   ```

4. **Create Production Container Apps**
   ```bash
   # Frontend App
   az containerapp create \
     --name frontend \
     --resource-group myapp-rg \
     --environment myapp-env \
     --image mcr.microsoft.com/azuredocs/containerapps-helloworld \
     --target-port 80 \
     --ingress external \
     --min-replicas 1 \
     --max-replicas 5

   # Backend App
   az containerapp create \
     --name backend \
     --resource-group myapp-rg \
     --environment myapp-env \
     --image mcr.microsoft.com/azuredocs/containerapps-helloworld \
     --target-port 8000 \
     --ingress external \
     --min-replicas 1 \
     --max-replicas 5
   ```

5. **Create Service Principal**
   ```bash
   az ad sp create-for-rbac \
     --name "myapp-github-actions" \
     --role contributor \
     --scopes /subscriptions/{subscription-id}/resourceGroups/myapp-rg \
     --sdk-auth
   ```
   Add the output JSON to GitHub secrets as AZURE_CREDENTIALS.

## Deployment Strategy

With trunk-based development:
- Every merge to main triggers a deployment
- Images are tagged with commit SHA and 'latest'
- Automatic version tags are created for each deployment
- Rollbacks are handled by redeploying previous tagged versions

### Quick Rollback Process
```bash
# Get previous successful deployment tag
az containerapp revision list -n frontend -g myapp-rg --query "[].{Tag:template.containers[0].image}" -o tsv

# Rollback to specific version
az containerapp update -n frontend -g myapp-rg --image $REGISTRY_LOGIN_SERVER/frontend:specific-tag
```

## Monitoring and Debugging

1. **Enable Application Insights**
   ```bash
   az monitor app-insights component create \
     --app myapp-insights \
     --location eastus \
     --resource-group myapp-rg \
     --application-type web
   ```

2. **Add Monitoring to Container Apps**
   ```bash
   az containerapp update \
     --name frontend \
     --resource-group myapp-rg \
     --set-env-vars APPLICATIONINSIGHTS_CONNECTION_STRING="{connection-string}"
   ```

## Production Safeguards

1. **Automated Checks**
   - All tests must pass before deployment
   - Smoke tests run after deployment
   - Automatic rollback on failed smoke tests

2. **Monitoring**
   - Set up alerts for error spikes
   - Monitor deployment success rates
   - Track application performance metrics

## Best Practices

1. **Deployment Safety**
   - Use feature flags for larger changes
   - Implement gradual rollouts
   - Monitor error rates post-deployment

2. **Image Management**
   - Clean up old images regularly
   - Maintain immutable tags
   - Keep 'latest' tag updated

3. **Security**
   - Use managed identities
   - Rotate credentials regularly
   - Keep dependencies updated

## Cost Management

1. **Resource Optimization**
   - Configure proper scaling rules
   - Monitor resource usage
   - Clean up unused resources

2. **Development Resources**
   - Use Basic SKU for development
   - Implement auto-shutdown for non-production
   - Monitor bandwidth usage