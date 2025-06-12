# Rasa Cloud Deployment Script for Windows PowerShell
# This script automates deployment to Docker Hub and prepares for cloud deployment

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerHubUsername,
    
    [Parameter(Mandatory=$false)]
    [string]$Platform = "dockerhub"
)

Write-Host "🌩️ Starting Rasa Cloud Deployment..." -ForegroundColor Green

# Check prerequisites
function Check-Prerequisites {
    Write-Host "📋 Checking prerequisites..." -ForegroundColor Cyan
    
    # Check Docker
    try {
        docker --version | Out-Null
        Write-Host "✅ Docker found" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker not found. Please install Docker first." -ForegroundColor Red
        exit 1
    }
    
    # Check if logged into Docker Hub
    try {
        docker info | Select-String "Username" | Out-Null
        Write-Host "✅ Docker Hub logged in" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Please login to Docker Hub first: docker login" -ForegroundColor Yellow
        exit 1
    }
}

# Build and push to Docker Hub
function Deploy-ToDockerHub {
    Write-Host "🐳 Building and pushing to Docker Hub..." -ForegroundColor Cyan
    
    # Build images
    Write-Host "🔨 Building Rasa Actions image..." -ForegroundColor Yellow
    docker build -f Dockerfile.rasa-actions -t "$DockerHubUsername/rasa-actions:latest" .
    
    Write-Host "🔨 Building Rasa Main image..." -ForegroundColor Yellow
    docker build -f Dockerfile.rasa-main -t "$DockerHubUsername/rasa-main:latest" .
    
    # Push images
    Write-Host "⬆️ Pushing Rasa Actions to Docker Hub..." -ForegroundColor Yellow
    docker push "$DockerHubUsername/rasa-actions:latest"
    
    Write-Host "⬆️ Pushing Rasa Main to Docker Hub..." -ForegroundColor Yellow
    docker push "$DockerHubUsername/rasa-main:latest"
    
    Write-Host "✅ Images successfully pushed to Docker Hub!" -ForegroundColor Green
    Write-Host "📋 Your images:" -ForegroundColor White
    Write-Host "   - Actions: $DockerHubUsername/rasa-actions:latest" -ForegroundColor White
    Write-Host "   - Main: $DockerHubUsername/rasa-main:latest" -ForegroundColor White
}

# Generate Render deployment instructions
function Generate-RenderInstructions {
    Write-Host "📝 Generating Render deployment instructions..." -ForegroundColor Cyan
    
    $instructions = @"
🚀 **Next Steps: Deploy to Render**

1. **Go to Render.com and sign up/login**
   https://render.com

2. **Deploy Rasa Actions Server:**
   - Click "New +" → "Web Service"
   - Source: "Deploy from Docker Hub"
   - Image URL: $DockerHubUsername/rasa-actions:latest
   - Name: rasa-actions
   - Port: 5055
   - Environment Variables:
     OPENAI_API_KEY=your_openai_api_key_here
   - Health Check Path: /health

3. **Deploy Rasa Main Server:**
   - Click "New +" → "Web Service"
   - Source: "Deploy from Docker Hub"
   - Image URL: $DockerHubUsername/rasa-main:latest
   - Name: rasa-main
   - Port: 5005
   - Environment Variables:
     ACTION_ENDPOINT_URL=https://rasa-actions-xxxx.onrender.com/webhook
     (Replace xxxx with your actual Render actions service URL)

4. **Test Your Deployment:**
   - Actions Server: https://rasa-actions-xxxx.onrender.com/health
   - Main Server: https://rasa-main-xxxx.onrender.com/webhooks/rest/webhook
   
5. **Test Bot:**
   curl -X POST https://rasa-main-xxxx.onrender.com/webhooks/rest/webhook \
     -H "Content-Type: application/json" \
     -d '{"sender": "test", "message": "hello"}'

📌 **Important Notes:**
- Free tier may have cold starts (first request takes 30+ seconds)
- Upgrade to paid plan for production use
- Set up custom domain if needed
- Monitor logs in Render dashboard
"@

    $instructions | Out-File -FilePath "render-deployment-instructions.txt" -Encoding UTF8
    Write-Host "✅ Instructions saved to: render-deployment-instructions.txt" -ForegroundColor Green
    Write-Host $instructions -ForegroundColor White
}

# Generate cloud deployment files
function Generate-CloudFiles {
    Write-Host "📄 Generating cloud deployment files..." -ForegroundColor Cyan
    
    # Docker Compose for cloud
    $cloudCompose = @"
version: '3.8'

services:
  rasa-actions:
    image: $DockerHubUsername/rasa-actions:latest
    container_name: rasa-actions-cloud
    ports:
      - "5055:5055"
    environment:
      - OPENAI_API_KEY=${'$'}{OPENAI_API_KEY}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5055/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  rasa-main:
    image: $DockerHubUsername/rasa-main:latest
    container_name: rasa-main-cloud
    ports:
      - "5005:5005"
    environment:
      - ACTION_ENDPOINT_URL=http://rasa-actions:5055/webhook
    depends_on:
      - rasa-actions
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5005/"]
      interval: 30s
      timeout: 10s
      retries: 3
"@

    $cloudCompose | Out-File -FilePath "docker-compose.cloud.yml" -Encoding UTF8
    Write-Host "✅ Created: docker-compose.cloud.yml" -ForegroundColor Green
}

# Main execution
Check-Prerequisites

switch ($Platform.ToLower()) {
    "dockerhub" {
        Deploy-ToDockerHub
        Generate-RenderInstructions
        Generate-CloudFiles
    }
    default {
        Write-Host "❌ Unsupported platform: $Platform" -ForegroundColor Red
        Write-Host "Supported platforms: dockerhub" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "🎉 Cloud deployment preparation complete!" -ForegroundColor Green
Write-Host "📖 Check the generated files for next steps." -ForegroundColor Cyan 