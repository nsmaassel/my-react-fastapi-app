@echo off
setlocal enabledelayedexpansion

REM Set default values
set LOCATION=eastus
set PROJECT_NAME=reactfastapi
set ENVIRONMENT=test

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :check_args
if "%~1"=="-d" (
    set ACTION=deploy
    shift
    goto :parse_args
)
if "%~1"=="--deploy" (
    set ACTION=deploy
    shift
    goto :parse_args
)
if "%~1"=="-c" (
    set ACTION=cleanup
    shift
    goto :parse_args
)
if "%~1"=="--cleanup" (
    set ACTION=cleanup
    shift
    goto :parse_args
)
if "%~1"=="-n" (
    set PROJECT_NAME=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-l" (
    set LOCATION=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-e" (
    set ENVIRONMENT=%~2
    shift
    shift
    goto :parse_args
)
echo Unknown parameter: %~1
goto :usage

:check_args
if "%ACTION%"=="" goto :usage

REM Set resource names
set RESOURCE_GROUP=%PROJECT_NAME%-%ENVIRONMENT%-rg
set ACR_NAME=%PROJECT_NAME%%ENVIRONMENT%acr
set ENV_NAME=%PROJECT_NAME%-%ENVIRONMENT%-env

if "%ACTION%"=="deploy" goto :deploy_resources
if "%ACTION%"=="cleanup" goto :cleanup_resources
goto :usage

:deploy_resources
echo Creating or updating resource group...
call az group create --name "%RESOURCE_GROUP%" --location "%LOCATION%"
if errorlevel 1 exit /b %errorlevel%

echo Creating Azure Container Registry...
call az deployment group create ^
    --mode Incremental ^
    --resource-group "%RESOURCE_GROUP%" ^
    --template-file acr.bicep ^
    --parameters ^
        containerRegistryName="%ACR_NAME%"
if errorlevel 1 exit /b %errorlevel%

echo Getting ACR login server...
for /f "tokens=* usebackq" %%a in (`az acr show --name "%ACR_NAME%" --resource-group "%RESOURCE_GROUP%" --query loginServer -o tsv`) do (
    set ACR_LOGIN_SERVER=%%a
)

echo Getting backend URL for frontend configuration...
for /f "tokens=* usebackq" %%a in (`az containerapp show -n backend -g "%RESOURCE_GROUP%" --query "properties.configuration.ingress.fqdn" -o tsv 2^>nul`) do (
    set BACKEND_URL=%%a
)

echo Logging into ACR...
call az acr login --name "%ACR_NAME%"
if errorlevel 1 (
    echo Failed to log into ACR
    exit /b 1
)

echo Building and pushing Docker images...
echo Building backend image...
cd ..
docker build -t "%ACR_LOGIN_SERVER%/backend:latest" -f backend/Dockerfile.prod ./backend
if errorlevel 1 (
    echo Backend build failed
    exit /b 1
)

echo Pushing backend image...
docker push "%ACR_LOGIN_SERVER%/backend:latest"
if errorlevel 1 (
    echo Backend push failed
    exit /b 1
)

echo Building frontend image...
if defined BACKEND_URL (
    echo Using existing backend URL: https://%BACKEND_URL%
    set "VITE_API_URL=https://%BACKEND_URL%"
    echo VITE_API_URL set to: !VITE_API_URL!
    docker build -t "%ACR_LOGIN_SERVER%/frontend:latest" ^
        --build-arg VITE_API_URL=!VITE_API_URL! ^
        -f frontend/Dockerfile.prod ./frontend
) else (
    echo WARNING: No existing backend URL found, will rely on post-deployment configuration
    docker build -t "%ACR_LOGIN_SERVER%/frontend:latest" -f frontend/Dockerfile.prod ./frontend
)
if errorlevel 1 (
    echo Frontend build failed
    exit /b 1
)

echo Pushing frontend image...
docker push "%ACR_LOGIN_SERVER%/frontend:latest"
if errorlevel 1 (
    echo Frontend push failed
    exit /b 1
)

cd infrastructure

echo Creating Container Apps Environment and deploying apps...
call az deployment group create ^
    --mode Incremental ^
    --resource-group "%RESOURCE_GROUP%" ^
    --template-file main.test.bicep ^
    --parameters ^
        environmentName="%ENV_NAME%" ^
        containerRegistryName="%ACR_NAME%"

echo.
echo ✨ Deployment Summary:
echo ====================
echo Resource Group: %RESOURCE_GROUP%
echo Location: %LOCATION%
echo ACR: %ACR_NAME%
echo Container Apps Environment: %ENV_NAME%
echo.
echo 🔗 Application URLs:

echo Getting endpoints...
for /f "tokens=* usebackq" %%a in (`az containerapp show -n frontend -g "%RESOURCE_GROUP%" --query "properties.configuration.ingress.fqdn" -o tsv`) do (
    set FRONTEND_URL=%%a
    echo Frontend URL: https://%%a
)
for /f "tokens=* usebackq" %%a in (`az containerapp show -n backend -g "%RESOURCE_GROUP%" --query "properties.configuration.ingress.fqdn" -o tsv`) do (
    set BACKEND_URL=%%a
    echo Backend URL: https://%%a
    echo Health Check: https://%%a/api/health
)

echo.
echo Updating container configurations with proper URLs...
call az containerapp update -n frontend -g "%RESOURCE_GROUP%" --set-env-vars VITE_API_URL=https://%BACKEND_URL%
call az containerapp update -n backend -g "%RESOURCE_GROUP%" --set-env-vars ENVIRONMENT=production BACKEND_CORS_ORIGINS="[\"https://%FRONTEND_URL%\"]"

echo.
echo Waiting for frontend to be ready with new configuration...
timeout /t 30 /nobreak

echo Verifying frontend configuration...
curl -s https://%FRONTEND_URL%/env.js

echo.
echo 🔍 To check app status:
echo az containerapp show -n frontend -g %RESOURCE_GROUP% --query "properties.latestRevision"
echo az containerapp show -n backend -g %RESOURCE_GROUP% --query "properties.latestRevision"
echo.
echo 🧹 To clean up resources later, run:
echo %~f0 -c -n %PROJECT_NAME% -e %ENVIRONMENT%
exit /b 0

:cleanup_resources
echo Warning: This will delete the entire resource group: %RESOURCE_GROUP%
echo This action cannot be undone.
set /p CONFIRM=Are you sure you want to continue? (y/N) 
if /i "%CONFIRM%"=="y" (
    echo Deleting resource group...
    call az group delete --name "%RESOURCE_GROUP%" --yes --no-wait
    echo Cleanup initiated. Resource group deletion is in progress...
    echo It may take a few minutes for all resources to be deleted.
) else (
    echo Cleanup cancelled.
)
exit /b 0

:usage
echo Usage: %0 [-d^|--deploy^|-c^|--cleanup] [-n PROJECT_NAME] [-l LOCATION] [-e ENVIRONMENT]
echo   -d, --deploy    Deploy resources
echo   -c, --cleanup   Cleanup resources
echo   -n              Project name (default: reactfastapi)
echo   -l              Location (default: eastus)
echo   -e              Environment (default: test)
exit /b 1