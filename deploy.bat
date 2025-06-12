@echo off
REM Rasa Deployment Script for Windows
REM This script helps deploy Rasa main server and actions server using Docker

echo 🚀 Starting Rasa Deployment...

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker first.
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    exit /b 1
)

REM Function to create .env file if it doesn't exist
if not exist .env (
    echo 📝 Creating .env file...
    (
        echo # Environment variables for Rasa deployment
        echo OPENAI_API_KEY=your_openai_api_key_here
        echo.
        echo # Action server endpoint ^(automatically set by Docker Compose^)
        echo ACTION_ENDPOINT_URL=http://rasa-actions:5055/webhook
        echo.
        echo # Optional: Set to production for deployment
        echo ENVIRONMENT=development
    ) > .env
    echo ✅ .env file created. Please update it with your OpenAI API key.
    echo ⚠️  Please edit .env file and add your OPENAI_API_KEY before continuing.
    pause
)

REM Handle command line arguments
set command=%1

if "%command%"=="dev" goto deploy_dev
if "%command%"=="development" goto deploy_dev
if "%command%"=="prod" goto deploy_prod
if "%command%"=="production" goto deploy_prod
if "%command%"=="status" goto show_status
if "%command%"=="logs" goto show_logs
if "%command%"=="stop" goto stop_services
goto show_usage

:deploy_dev
echo 🔧 Deploying in development mode...
docker-compose down
docker-compose build
docker-compose up -d
echo ✅ Development deployment complete!
echo 📋 Services:
echo    - Rasa Main Server: http://localhost:5005
echo    - Rasa Actions Server: http://localhost:5055
goto end

:deploy_prod
echo 🏭 Deploying in production mode...
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
echo ✅ Production deployment complete!
echo 📋 Services:
echo    - Rasa Main Server: http://localhost:5005
echo    - Rasa Actions Server: http://localhost:5055
goto end

:show_status
echo 📊 Service Status:
docker-compose ps
goto end

:show_logs
echo 📝 Service Logs:
docker-compose logs -f
goto end

:stop_services
echo 🛑 Stopping services...
docker-compose down
echo ✅ Services stopped.
goto end

:show_usage
echo Usage: %0 {dev^|prod^|status^|logs^|stop}
echo.
echo Commands:
echo   dev        - Deploy in development mode
echo   prod       - Deploy in production mode
echo   status     - Show service status
echo   logs       - Show service logs
echo   stop       - Stop all services
exit /b 1

:end 