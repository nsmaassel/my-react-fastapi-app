#!/bin/bash

# AZURE_DEPLOYMENT: Automated deployment script
# RESOURCE_SETUP: Azure Container Registry, Container Apps, Service Principal
# DEPLOYMENT_TYPE: Infrastructure and Credentials Setup

# Check for required tools
command -v az >/dev/null 2>&1 || { echo "Azure CLI is required but not installed. Aborting." >&2; exit 1; }

# Configuration
SUBSCRIPTION_NAME="your-subscription"
RESOURCE_GROUP="your-app-rg"
LOCATION="eastus"
ENVIRONMENT_NAME="prod-env"
ACR_NAME="yourappregistry"
DOMAIN_NAME="yourdomain.com"

# Login to Azure if not already logged in
az account show >/dev/null 2>&1 || az login

# Set subscription
az account set --subscription "$SUBSCRIPTION_NAME"

# Create resource group
echo "Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Deploy Bicep template
echo "Deploying infrastructure..."
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file infrastructure/main.bicep \
  --parameters \
    environmentName="$ENVIRONMENT_NAME" \
    containerRegistryName="$ACR_NAME" \
    customDomainName="$DOMAIN_NAME"

# Get ACR credentials
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)

# Create service principal for GitHub Actions
echo "Creating service principal for GitHub Actions..."
SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "${ENVIRONMENT_NAME}-github-actions" \
  --role contributor \
  --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP" \
  --sdk-auth)

# Output important values
echo "
Please add the following secrets to your GitHub repository:

AZURE_CREDENTIALS='$SP_OUTPUT'
REGISTRY_LOGIN_SERVER='$ACR_LOGIN_SERVER'
REGISTRY_USERNAME='$ACR_NAME'
REGISTRY_PASSWORD='$ACR_PASSWORD'
REGISTRY_NAME='$ACR_NAME'

And add these variables:

AZURE_RESOURCE_GROUP='$RESOURCE_GROUP'
AZURE_APP_HOSTNAME='$DOMAIN_NAME'
AZURE_LOCATION='$LOCATION'

Next steps:
1. Add these secrets and variables to your GitHub repository
2. Configure your custom domain DNS settings
3. Push to main branch to trigger first deployment
"