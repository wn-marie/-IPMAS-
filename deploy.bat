@echo off
REM IPMAS Deployment Script for Windows
REM Quick deployment helper script

echo.
echo 🚀 IPMAS Deployment Helper
echo ==========================
echo.

REM Check if .env files exist
if not exist "backend\.env" (
    echo ⚠️  backend\.env not found
    echo Creating from template...
    if exist "backend\env" (
        copy backend\env backend\.env
        echo ✓ Created backend\.env from template
        echo ⚠️  Please edit backend\.env with your production values
    ) else (
        echo ✗ backend\env template not found
        exit /b 1
    )
) else (
    echo ✓ backend\.env exists
)

echo.
echo Checking Docker installation...

REM Check Docker
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Docker is not installed
    echo Please install Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
    exit /b 1
) else (
    echo ✓ Docker is installed
    docker --version
)

where docker-compose >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Docker Compose is not installed
    exit /b 1
) else (
    echo ✓ Docker Compose is installed
    docker-compose --version
)

echo.
echo Select deployment method:
echo 1) Docker Compose (Local/Server)
echo 2) View deployment guides
echo 3) Exit
echo.
set /p choice="Enter choice [1-3]: "

if "%choice%"=="1" (
    echo.
    echo Deploying with Docker Compose...
    if exist "docker-compose.prod.yml" (
        echo Using docker-compose.prod.yml
        docker-compose -f docker-compose.prod.yml up -d --build
    ) else (
        echo Using docker-compose.yml
        docker-compose up -d --build
    )
    echo.
    echo ✓ Deployment started
    echo.
    echo View logs with: docker-compose logs -f
    echo Stop with: docker-compose down
) else if "%choice%"=="2" (
    echo.
    echo 📚 Deployment Guides:
    echo - Quick Start: DEPLOYMENT_QUICK_START.md
    echo - Full Guide: DEPLOYMENT_GUIDE.md
) else if "%choice%"=="3" (
    echo Goodbye!
    exit /b 0
) else (
    echo Invalid choice
    exit /b 1
)

pause

