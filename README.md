# Containerized React + FastAPI Demo

<!-- CICD_DEPLOYMENT_CONFIG: React + FastAPI application with Azure Container Apps deployment -->
<!-- AZURE_DEPLOYMENT: True -->

A minimal, production-ready demo showing how to:
1. Run React and FastAPI applications in Docker
2. Set up container-to-container communication
3. Handle development hot-reloading in containers
4. Implement end-to-end testing for containerized apps

## Quick Start

Prerequisites:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

```bash
# Clone and start
git clone https://github.com/yourusername/react-fastapi-docker-demo
cd react-fastapi-docker-demo
docker-compose up
```

Then visit:
- Frontend: http://localhost:3000
- API Docs: http://localhost:8000/api/docs

## What's Included

### Frontend (React + TypeScript + Vite)
- Production-grade React setup with TypeScript
- Hot Module Replacement (HMR) working in Docker
- Proxy configuration for API requests
- End-to-end tests with Playwright

### Backend (FastAPI + Python)
- RESTful API with automatic documentation
- Health checks and monitoring endpoints
- CORS configuration for frontend requests
- Production-ready with Gunicorn

### Docker Configuration
- Development environment with hot-reload
- Production builds with multi-stage Dockerfiles
- Container health checks and networking
- End-to-end test environment

## Development Workflow

1. Start development environment:
```bash
docker-compose up
```

2. Make changes to either frontend or backend code - they will auto-reload

3. Run tests:
```bash
docker-compose up e2e
```

## Production Deployment

1. Build production images:
```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
```

2. Run production stack:
```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

Azure deployment instructions available in [AZURE_SETUP.md](AZURE_SETUP.md).

## Deployment & CI/CD

This project is configured for deployment to Azure Container Apps with a complete CI/CD pipeline.

### Key Files
- `.github/workflows/` - CI/CD pipeline configurations
- `infrastructure/` - Azure infrastructure as code (Bicep)
- `AZURE_SETUP.md` - Complete Azure deployment guide
- `docker-compose.ci.yml` - CI/CD specific Docker configuration

See [AZURE_SETUP.md](AZURE_SETUP.md) for complete deployment instructions.

## Project Structure
```
.
├── frontend/                # React application
│   ├── src/                # React source code
│   ├── e2e/                # Playwright tests
│   └── Dockerfile*         # Dev, prod, and e2e builds
├── backend/                # FastAPI application
│   ├── app/               # API source code
│   ├── tests/             # Python tests
│   └── Dockerfile*        # Dev and prod builds
└── docker-compose*.yml    # Dev, prod, and CI configs
```

## Key Features Demonstrated

1. **Docker Development Environment**
   - Hot-reloading for both React and FastAPI
   - Volume mounts for local development
   - Container health checks

2. **Frontend-Backend Integration**
   - API proxy configuration
   - CORS setup
   - TypeScript interfaces for API types

3. **Testing Strategy**
   - End-to-end tests with Playwright
   - Container-aware test configuration
   - CI/CD ready test setup

## Common Tasks

### Adding Backend Dependencies
1. Add to `backend/requirements.txt`
2. Rebuild backend container:
```bash
docker-compose build backend
```

### Adding Frontend Dependencies
1. Add to `frontend/package.json`
2. Rebuild frontend container:
```bash
docker-compose build frontend
```

### Running Specific Tests
```bash
# Run specific e2e test
docker-compose run --rm e2e npx playwright test my-test.spec.ts
```

## Troubleshooting

1. **HMR Not Working**
   - Check WebSocket port exposure (24678)
   - Verify frontend container logs
   - Ensure proper network configuration

2. **Backend Not Responding**
   - Check backend health at `/api/health`
   - Verify CORS settings
   - Check container logs

3. **Tests Failing**
   - Increase timeouts for containerized environment
   - Check container connectivity
   - Verify test environment variables

## Learn More

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Playwright Documentation](https://playwright.dev/)

## License

MIT