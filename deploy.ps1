# Rasa Deployment Script for Windows PowerShell
# This script helps deploy Rasa main server and actions server using Docker

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "development", "prod", "production", "status", "logs", "stop")]
    [string]$Command
)

Write-Host "🚀 Starting Rasa Deployment..." -ForegroundColor Green

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker found" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker first." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is installed
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose found" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not installed. Please install Docker Compose first." -ForegroundColor Red
    exit 1
}

# Function to create .env file if it doesn't exist
function Create-EnvFile {
    if (!(Test-Path ".env")) {
        Write-Host "📝 Creating .env file..." -ForegroundColor Yellow
        @"
# Environment variables for Rasa deployment
OPENAI_API_KEY=your_openai_api_key_here

# Action server endpoint (automatically set by Docker Compose)
ACTION_ENDPOINT_URL=http://rasa-actions:5055/webhook

# Optional: Set to production for deployment
ENVIRONMENT=development
"@ | Out-File -FilePath ".env" -Encoding UTF8
        
        Write-Host "✅ .env file created. Please update it with your OpenAI API key." -ForegroundColor Green
        Write-Host "⚠️  Please edit .env file and add your OPENAI_API_KEY before continuing." -ForegroundColor Yellow
        Read-Host "Press Enter to continue after updating .env file"
    }
}

# Function to deploy in development mode
function Deploy-Dev {
    Write-Host "🔧 Deploying in development mode..." -ForegroundColor Cyan
    Create-EnvFile
    docker-compose down
    docker-compose build
    docker-compose up -d
    Write-Host "✅ Development deployment complete!" -ForegroundColor Green
    Write-Host "📋 Services:" -ForegroundColor White
    Write-Host "   - Rasa Main Server: http://localhost:5005" -ForegroundColor White
    Write-Host "   - Rasa Actions Server: http://localhost:5055" -ForegroundColor White
}

# Function to deploy in production mode
function Deploy-Prod {
    Write-Host "🏭 Deploying in production mode..." -ForegroundColor Cyan
    Create-EnvFile
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.prod.yml build
    docker-compose -f docker-compose.prod.yml up -d
    Write-Host "✅ Production deployment complete!" -ForegroundColor Green
    Write-Host "📋 Services:" -ForegroundColor White
    Write-Host "   - Rasa Main Server: http://localhost:5005" -ForegroundColor White
    Write-Host "   - Rasa Actions Server: http://localhost:5055" -ForegroundColor White
}

# Function to show status
function Show-Status {
    Write-Host "📊 Service Status:" -ForegroundColor Cyan
    docker-compose ps
}

# Function to show logs
function Show-Logs {
    Write-Host "📝 Service Logs:" -ForegroundColor Cyan
    docker-compose logs -f
}

# Function to stop services
function Stop-Services {
    Write-Host "🛑 Stopping services..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✅ Services stopped." -ForegroundColor Green
}

# Main execution
switch ($Command) {
    { $_ -in @("dev", "development") } { Deploy-Dev }
    { $_ -in @("prod", "production") } { Deploy-Prod }
    "status" { Show-Status }
    "logs" { Show-Logs }
    "stop" { Stop-Services }
} 