# Scripts Reference

## Active Scripts

### Windows (.bat)
These are the primary scripts used for deployment and testing on Windows:

1. `infrastructure/deploy-test.bat`
   - Main deployment script for test environment
   - Handles Azure Container Apps deployment
   - Usage: `deploy-test.bat -d -n projectname -e test`

2. `scripts/test-deployment.bat`
   - Local development and testing script
   - Manages Docker containers and e2e tests
   - Usage: `test-deployment.bat [up|down|clean]`

### Azure Infrastructure (.bicep)
These Bicep files define our Azure resources:

1. `infrastructure/main.bicep`
   - Production environment infrastructure
   - Premium ACR, custom domains, higher resource limits
   - Used by GitHub Actions production deployment

2. `infrastructure/main.test.bicep`
   - Test environment infrastructure
   - Basic ACR, no custom domains, lower resource limits
   - Used by deploy-test.bat for test deployments

3. `infrastructure/acr.bicep`
   - Azure Container Registry definition
   - Used by both test and production deployments

## Script Details

### deploy-test.bat
```batch
Usage: deploy-test.bat [-d|--deploy|-c|--cleanup] [-n PROJECT_NAME] [-l LOCATION] [-e ENVIRONMENT]
  -d, --deploy    Deploy resources
  -c, --cleanup   Cleanup resources
  -n              Project name (default: reactfastapi)
  -l              Location (default: eastus)
  -e              Environment (default: test)
```

### test-deployment.bat
```batch
Usage: test-deployment.bat [up|down|clean]
  up    - Start local deployment
  down  - Stop local deployment
  clean - Clean up all resources
```

## Environment Variables

### Production Deployment
- `AZURE_APP_HOSTNAME`: Custom domain for production
- `AZURE_RESOURCE_GROUP`: Production resource group
- `REGISTRY_LOGIN_SERVER`: ACR login server
- `REGISTRY_USERNAME`: ACR username
- `REGISTRY_PASSWORD`: ACR password

### Test Deployment
- `VITE_API_URL`: Backend API URL
- `BACKEND_CORS_ORIGINS`: CORS configuration
- `ENVIRONMENT`: Deployment environment (test/prod)

## Note on Platform Support

This project primarily supports Windows development environments with PowerShell/Command Prompt. If you need to run on Linux/macOS, you'll need to:

1. Convert .bat scripts to .sh equivalents
2. Update GitHub Actions workflow accordingly
3. Test deployment steps on your target platform

The Bicep files and Docker configurations are platform-independent and will work on any environment.