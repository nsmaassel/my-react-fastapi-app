# Deployment Checklist

## Pre-Deployment
- [ ] Check for old/unused resource groups
      ```bash
      az group list --query "[?starts_with(name, 'your-project-prefix')]"
      ```
- [ ] Verify local tests pass
      ```bash
      ./scripts/test-deployment.bat up
      ```
- [ ] Build and test Docker images locally
- [ ] Check environment variables are set correctly

## Deployment Steps

### 1. Resource Group Setup
- [ ] Use consistent naming: `{projectName}-{environment}-rg`
- [ ] Create in correct region
- [ ] Verify permissions

### 2. Container Registry
- [ ] Login successful
- [ ] Images tagged correctly
- [ ] Old images cleaned up

### 3. Backend Deployment
- [ ] Environment variables configured:
  - ENVIRONMENT
  - BACKEND_CORS_ORIGINS
  - WORKERS_COUNT
  - TIMEOUT
  - KEEP_ALIVE
- [ ] Health check endpoint responds
- [ ] CORS headers verified

### 4. Frontend Deployment
- [ ] VITE_API_URL points to correct backend
- [ ] env.js generation verified
- [ ] Static assets served correctly
- [ ] No CORS errors in console

## Post-Deployment Verification

### Backend
- [ ] `/api/health` returns 200
- [ ] Metrics show proper environment
- [ ] CORS allows frontend origin

### Frontend
- [ ] Loads without errors
- [ ] API calls succeed
- [ ] Environment configuration correct
- [ ] Performance metrics acceptable

## Cleanup
- [ ] Remove old revisions
- [ ] Delete unused resource groups
- [ ] Clean up local test resources:
      ```bash
      ./scripts/test-deployment.bat clean
      ```

## Rollback Plan
1. Identify last known good revision
2. Revert to previous container image
3. Verify backend API compatibility
4. Check frontend configuration