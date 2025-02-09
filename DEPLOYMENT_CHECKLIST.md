# Azure Deployment Checklist

## 1. Git Repository Setup
- [ ] Initialize Git repository (if not already done)
- [ ] Create new repository on GitHub
- [ ] Add remote origin: `git remote add origin <your-repo-url>`
- [ ] Make initial commit and push

## 2. Azure Infrastructure Setup
- [ ] Update deploy.sh configuration values:
  ```
  SUBSCRIPTION_NAME="your-subscription"
  RESOURCE_GROUP="your-app-rg"
  LOCATION="eastus"
  ENVIRONMENT_NAME="prod-env"
  ACR_NAME="yourappregistry"  # Must be globally unique
  DOMAIN_NAME="yourdomain.com"
  ```
- [ ] Install Azure CLI if not already installed
- [ ] Run `deploy.sh` script to create Azure resources

## 3. GitHub Repository Configuration
### Add Secrets:
- [ ] AZURE_CREDENTIALS (Service Principal JSON)
- [ ] REGISTRY_LOGIN_SERVER (ACR URL)
- [ ] REGISTRY_USERNAME (ACR name)
- [ ] REGISTRY_PASSWORD (ACR password)
- [ ] REGISTRY_NAME (ACR name)

### Add Variables:
- [ ] AZURE_RESOURCE_GROUP
- [ ] AZURE_APP_HOSTNAME
- [ ] AZURE_LOCATION

## 4. DNS Configuration
- [ ] Add CNAME record for main domain pointing to Azure Container Apps
  - Record: `@` or your subdomain
  - Value: Your Container Apps frontend URL
- [ ] Add CNAME record for API subdomain
  - Record: `api`
  - Value: Your Container Apps backend URL

## 5. Initial Deployment
- [ ] Push code to main branch: `git push origin main`
- [ ] Monitor GitHub Actions workflow
- [ ] Verify deployment at:
  - Frontend: `https://<your-domain>`
  - Backend: `https://api.<your-domain>`
  - Health check: `https://api.<your-domain>/api/health`

## 6. Post-Deployment Verification
- [ ] Check Application Insights for logs
- [ ] Verify CORS is working (frontend can call backend)
- [ ] Test all API endpoints through frontend
- [ ] Verify frontend features are working

## 7. Security and Monitoring
- [ ] Set up monitoring alerts in Azure Portal
- [ ] Set up error rate alerts
- [ ] Configure scaling rules if needed
- [ ] Review security settings

## Troubleshooting
If deployment fails:
1. Check GitHub Actions logs
2. Verify Azure credentials are correct
3. Check Azure resource quotas
4. Verify domain DNS propagation
5. Check Container Apps logs in Azure Portal

## Rollback Procedure
If needed, you can roll back to a previous version:
```bash
# List revisions
az containerapp revision list -n frontend -g <resource-group> --query "[].{Tag:template.containers[0].image}" -o tsv

# Rollback to specific version
az containerapp update -n frontend -g <resource-group> --image <acr-url>/frontend:<previous-tag>
```