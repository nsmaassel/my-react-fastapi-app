# Containerized React + FastAPI Demo
<!-- CICD_DEPLOYMENT_CONFIG: React + FastAPI application with Azure Container Apps deployment -->
<!-- AZURE_DEPLOYMENT: True -->
<!-- PLATFORM: Windows -->
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnsmaassel%2Fmy-react-fastapi-app%2Fmain%2Finfrastructure%2Fazuredeploy.json)

A minimal, production-ready demo showing how to:
1. Run React and FastAPI applications in Docker
2. Set up container-to-container communication
3. Handle development hot-reloading in containers
4. Implement end-to-end testing for containerized apps

## System Requirements
- Windows 10/11 with PowerShell or Command Prompt
- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows)

## Quick Start (Local Development)
```batch
# Clone and start development environment
git clone https://github.com/yourusername/react-fastapi-docker-demo
cd react-fastapi-docker-demo
scripts\test-deployment.bat up
```

Access your local deployment:
- Frontend: http://localhost:3000
- API Docs: http://localhost:8000/api/docs
- Health Check: http://localhost:8000/api/health

## Architecture

### Frontend-Backend Communication
The application uses a robust URL configuration system:

1. **Development:**
   - Frontend proxy configuration in Vite
   - Automatic routing of `/api` requests
   - Hot-reloading enabled

2. **Production:**
   - Runtime configuration via `env.js`
   - Build-time configuration via `VITE_API_URL`
   - Absolute URLs for API requests

3. **URL Priority:**
   ```
   Runtime (env.js) → Build-time (VITE_API_URL) → Development Proxy
   ```

### Key Components

#### Frontend (React + TypeScript + Vite)
- Production-grade React setup with TypeScript
- Dynamic runtime configuration
- End-to-end tests with Playwright

#### Backend (FastAPI + Python)
- RESTful API with automatic documentation
- Health checks and monitoring
- Environment-aware CORS configuration

## Deployment Options

### 1. Quick Deploy to Azure (One-time Setup)
Click the "Deploy to Azure" button above and provide:
- Resource Group name (new or existing)
- Region
- Environment Name (e.g., 'prod' or 'staging')
- Container Registry name (must be globally unique)

No GitHub account or additional credentials needed - just your Azure login.

### 2. Continuous Deployment with GitHub Actions
For automated deployments on every push to main:
1. First deploy using the "Deploy to Azure" button above
2. Set up GitHub Actions by following [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

### 3. Script-based Deployment (Windows)
```batch
# Deploy test environment
cd infrastructure
deploy-test.bat -d -n yourprojectname -e test

# Clean up resources
deploy-test.bat -c -n yourprojectname -e test
```

### 4. Manual Deployment Steps
See [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for step-by-step instructions.

## Development Workflow

1. Start the development environment:
```batch
scripts\test-deployment.bat up
```

2. Make changes - both frontend and backend support hot-reload

3. Run tests:
```batch
scripts\test-deployment.bat test
```

4. Clean up:
```batch
scripts\test-deployment.bat clean
```

## Project Structure
```
.
├── frontend/              # React application
│   ├── src/              # React source code
│   ├── e2e/              # Playwright tests
│   └── nginx.conf        # Production server config
├── backend/              # FastAPI application
│   ├── app/             # API source code
│   └── tests/           # Python tests
├── infrastructure/       # Deployment configuration
│   ├── *.bicep          # Azure infrastructure as code
│   └── deploy-*.bat     # Deployment scripts
├── scripts/             # Development utilities
└── docs/               # Documentation
```

## Troubleshooting

### API Connection Issues
1. Check browser console for API URL
2. Verify env.js contains correct backend URL
3. Confirm CORS configuration matches frontend origin
4. Check Container App logs for connection errors

### Development Environment
1. **Hot-reload not working:**
   - Verify WebSocket ports (24678)
   - Check container logs
   - Restart development containers

2. **API not responding:**
   - Check `/api/health` endpoint
   - Verify proxy configuration
   - Review container logs

### Production Deployment
1. **Frontend can't reach backend:**
   - Verify Container Apps URLs
   - Check environment variables
   - Confirm CORS settings

2. **Resource cleanup:**
   - Remove unused resource groups
   - Clean up old Container App revisions
   - Delete unused container images

## Additional Resources
- [Deployment Tips](docs/DEPLOYMENT_TIPS.md)
- [Scripts Reference](docs/SCRIPTS.md)
- [Azure Setup Guide](AZURE_SETUP.md)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)

## Platform Support
This project is optimized for Windows environments. The deployment scripts (`*.bat`) and tooling assume a Windows environment with PowerShell or Command Prompt. For other platforms, you'll need to adapt the scripts accordingly.

## License
MIT