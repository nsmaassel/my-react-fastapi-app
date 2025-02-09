# Docker Compose Setup Guide

This document explains the Docker setup for our React + FastAPI application, including common pitfalls encountered and their solutions.

## Architecture Overview

The application consists of three main services:
- Frontend (Vite + React)
- Backend (FastAPI)
- E2E Tests (Playwright)

## Key Features

- Hot Module Replacement (HMR) working in Docker
- End-to-end testing with Playwright
- CORS and proxy configuration
- Health checks for all services
- Development-friendly volume mounts

## Common Pitfalls and Solutions

### 1. Vite HMR in Docker

**Problem**: WebSocket connections for HMR failing in Docker environment.

**Solution**: 
- Configure separate WebSocket port (24678)
- Set proper HMR host and client port settings
- Add network aliases in docker-compose.yml

```typescript
// vite.config.ts HMR configuration
hmr: {
  host: 'frontend',
  port: 24678,
  protocol: 'ws',
  clientPort: 24678
}
```

### 2. CORS and Proxy Configuration

**Problem**: Frontend unable to communicate with backend through proxy.

**Solution**:
- Configure CORS in FastAPI with proper origins
- Set up Vite proxy to forward API requests
- Use environment variables for flexible configuration

### 3. Docker Health Checks

**Problem**: Services starting in wrong order or before they're ready.

**Solution**: Implemented health checks for both frontend and backend:
- Backend: Checks `/api/health` endpoint
- Frontend: Verifies web server is responding
- E2E tests: Wait for both services to be healthy

### 4. Volume Mounts and Hot Reloading

**Problem**: Code changes not reflecting in containers.

**Solution**:
- Properly configured volume mounts
- Enable polling for file watching
- Exclude node_modules and build artifacts

## Service Configuration Details

### Frontend (Vite + React)

```yaml
# Key environment variables
- VITE_DEV_SERVER_HOST=0.0.0.0
- VITE_DEV_SERVER_PORT=3000
- VITE_HMR_HOST=frontend
- VITE_HMR_PORT=24678
```

### Backend (FastAPI)

```yaml
# Key environment variables
- PYTHONUNBUFFERED=1
- WATCHFILES_FORCE_POLLING=true
```

### E2E Tests (Playwright)

```yaml
# Key environment variables
- PLAYWRIGHT_TEST_BASE_URL=http://frontend:3000
- API_BASE_URL=http://backend:8000
```

## Development Workflow

1. Start all services:
   ```bash
   docker-compose up
   ```

2. Run e2e tests:
   ```bash
   docker-compose up e2e
   ```

3. View test results:
   - Reports are available in `playwright-results/`
   - Screenshots and videos of failed tests are automatically captured

## Common Docker Commands

### Development Workflow

1. **Start Development Environment**
   ```bash
   # Fresh start with rebuilding
   docker-compose down && docker-compose up --build

   # Quick start without rebuilding
   docker-compose up
   ```

2. **Run E2E Tests**
   ```bash
   # Run tests and exit
   docker-compose up --build --exit-code-from e2e e2e
   ```

3. **Troubleshooting Commands**
   ```bash
   # Force rebuild all images
   docker-compose down
   docker-compose build --no-cache
   docker-compose up

   # Quick restart without rebuild
   docker-compose restart

   # View logs
   docker-compose logs -f

   # Check container status
   docker-compose ps
   ```

4. **Cleanup Commands**
   ```bash
   # Remove all containers and networks
   docker-compose down

   # Remove everything including volumes
   docker-compose down -v

   # Remove unused images
   docker image prune -a
   ```

## Next Steps

1. **Production Configuration**
   - Add production Docker configurations
   - Implement multi-stage builds
   - Set up proper environment-specific settings

2. **CI/CD Integration**
   - Add GitHub Actions or similar CI/CD pipeline
   - Automate test runs and deployments
   - Implement caching strategies for faster builds

3. **Monitoring and Logging**
   - Add logging aggregation
   - Implement metrics collection
   - Set up monitoring dashboards

4. **Security Enhancements**
   - Implement proper secrets management
   - Add security scanning in CI/CD
   - Configure proper CORS for production

5. **Performance Optimization**
   - Optimize Docker image sizes
   - Implement caching strategies
   - Configure proper resource limits

## Troubleshooting

### WebSocket Connection Issues
If HMR isn't working:
1. Check WebSocket port exposure (24678)
2. Verify network aliases in docker-compose.yml
3. Ensure proper Vite HMR configuration

### CORS Issues
If API requests fail:
1. Check BACKEND_CORS_ORIGINS configuration
2. Verify proxy settings in vite.config.ts
3. Ensure proper protocol and port usage

### Volume Mount Issues
If code changes aren't reflecting:
1. Verify volume paths in docker-compose.yml
2. Check file watching configuration
3. Ensure proper file permissions

## Best Practices

1. **Development Environment**
   - Use volume mounts for hot reloading
   - Enable debug logging when needed
   - Utilize Docker health checks

2. **Testing**
   - Run e2e tests in isolated container
   - Configure proper timeouts for Docker environment
   - Implement retry mechanisms for flaky tests

3. **Configuration**
   - Use environment variables for configuration
   - Implement proper CORS settings
   - Configure proper networking between services