# Deployment Tips and Best Practices

## Frontend-Backend URL Configuration

### Key Points
- The frontend application uses a two-stage approach for API URL configuration:
  1. Build-time configuration via `VITE_API_URL` build argument
  2. Runtime configuration through `env.js` for dynamic updates

### Best Practices

1. **Always use absolute URLs**
   - Frontend requests should always use absolute URLs to the backend
   - The backend URL is injected via environment variables
   - Avoid relative URLs to prevent routing issues

2. **URL Configuration Flow**
   ```mermaid
   graph TD
       A[Runtime env.js] -->|Primary| B{URL Selection}
       C[Build-time VITE_API_URL] -->|Fallback| B
       B --> D[Validate URL]
       D -->|Valid| E[Use in API calls]
       D -->|Invalid| F[Log error]
   ```

3. **Environment Variable Hierarchy**
   - Runtime (`env.js`): Takes precedence, allows dynamic updates
   - Build-time (`VITE_API_URL`): Serves as fallback
   - Development proxy: Only used in local development

## Resource Group Management

### Best Practices

1. **Naming Convention**
   ```
   {projectName}-{environment}-rg
   Example: reactfastapi-test-rg, reactfastapi-prod-rg
   ```

2. **Clean Up Procedure**
   - Always clean up old resource groups when changing names
   - Use `az group delete --name <old-group-name> --yes`
   - Verify resources are gone before deploying new ones

3. **Environment Separation**
   - Keep test and production deployments in separate resource groups
   - Use different Container Apps Environment instances for isolation
   - Maintain separate ACR repositories for test/prod images

## Deployment Verification

### Checklist

1. **Pre-deployment**
   - [ ] Clean up any old/unused resource groups
   - [ ] Verify ACR login and permissions
   - [ ] Check CORS configuration in backend

2. **During deployment**
   - [ ] Monitor build logs for VITE_API_URL injection
   - [ ] Verify frontend env.js is generated correctly
   - [ ] Check Container Apps revisions are created

3. **Post-deployment**
   - [ ] Verify frontend can reach backend API
   - [ ] Check CORS headers in API responses
   - [ ] Monitor application logs for URL-related errors

### Troubleshooting

1. **Frontend API Issues**
   - Check browser console for API URL being used
   - Verify env.js contains correct backend URL
   - Ensure CORS is properly configured

2. **Backend Connectivity**
   - Verify health endpoint is accessible
   - Check Container App logs for any errors
   - Confirm networking rules allow communication

## Local Development

### Configuration
- Use docker-compose proxy configuration for local development
- Keep development and production configurations separate
- Test with production-like settings before deploying

### Testing
- Run e2e tests to verify frontend-backend communication
- Use test deployment before production
- Validate environment variables are correctly passed