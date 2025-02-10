@echo off
SETLOCAL EnableDelayedExpansion

REM Local Docker Testing Script
REM Usage: test-deployment.bat [up|down|clean]

IF "%1"=="" GOTO :usage

:check_prerequisites
echo 🔍 Checking prerequisites...
where docker >nul 2>&1 || (
    echo ❌ Docker is required but not installed. Aborting.
    EXIT /B 1
)
where docker-compose >nul 2>&1 || (
    echo ❌ Docker Compose is required but not installed. Aborting.
    EXIT /B 1
)
where curl >nul 2>&1 || (
    echo ❌ curl is required but not installed. Aborting.
    EXIT /B 1
)
GOTO :EOF

:wait_for_service
SET url=%~1
SET name=%~2
SET max_attempts=30
SET attempt=1

echo ⏳ Waiting for %name% to be ready...
:wait_loop
IF %attempt% GTR %max_attempts% (
    echo ❌ %name% failed to start after %max_attempts% attempts
    EXIT /B 1
)

curl -s %url% >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo ✅ %name% is ready
    EXIT /B 0
)
echo ⏳ Attempt %attempt%/%max_attempts%: %name% not ready yet...
timeout /t 2 /nobreak >nul
SET /A attempt+=1
GOTO :wait_loop

:setup_local
CALL :check_prerequisites
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

echo 🚀 Starting local deployment...

REM Create .env file if it doesn't exist
IF NOT EXIST ".\backend\.env" (
    echo 📝 Creating default .env file...
    echo ENVIRONMENT=development> .\backend\.env
)

REM Build and start services
docker-compose -f docker-compose.yml -f docker-compose.ci.yml build
docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d

REM Wait for services with improved health checks
CALL :wait_for_service "http://localhost:8000/api/health" "Backend API"
IF %ERRORLEVEL% NEQ 0 (
    docker-compose logs backend
    EXIT /B 1
)

CALL :wait_for_service "http://localhost:3000" "Frontend"
IF %ERRORLEVEL% NEQ 0 (
    docker-compose logs frontend
    EXIT /B 1
)

echo 🧪 Running e2e tests...
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm e2e

echo.
echo 📊 Local deployment is ready:
echo Frontend: http://localhost:3000
echo Backend API: http://localhost:8000/api/docs
echo Health Check: http://localhost:8000/api/health
echo.
EXIT /B 0

:teardown_local
echo 🛑 Stopping local deployment...
docker-compose -f docker-compose.yml -f docker-compose.ci.yml down
EXIT /B 0

:clean_local
echo 🧹 Cleaning up local deployment...
docker-compose -f docker-compose.yml -f docker-compose.ci.yml down -v
docker system prune -f
echo ✨ Cleanup complete
EXIT /B 0

:usage
echo Usage: %0 [up^|down^|clean]
echo   up    - Start local deployment
echo   down  - Stop local deployment
echo   clean - Clean up all resources
EXIT /B 1

IF "%1"=="up" GOTO :setup_local
IF "%1"=="down" GOTO :teardown_local
IF "%1"=="clean" GOTO :clean_local
GOTO :usage