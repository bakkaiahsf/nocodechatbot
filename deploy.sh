#!/bin/bash

# Rasa Deployment Script
# This script helps deploy Rasa main server and actions server using Docker

set -e

echo "🚀 Starting Rasa Deployment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Function to create .env file if it doesn't exist
create_env_file() {
    if [ ! -f .env ]; then
        echo "📝 Creating .env file..."
        cat > .env << EOF
# Environment variables for Rasa deployment
OPENAI_API_KEY=your_openai_api_key_here

# Action server endpoint (automatically set by Docker Compose)
ACTION_ENDPOINT_URL=http://rasa-actions:5055/webhook

# Optional: Set to production for deployment
ENVIRONMENT=development
EOF
        echo "✅ .env file created. Please update it with your OpenAI API key."
        echo "⚠️  Please edit .env file and add your OPENAI_API_KEY before continuing."
        read -p "Press Enter to continue after updating .env file..."
    fi
}

# Function to deploy in development mode
deploy_dev() {
    echo "🔧 Deploying in development mode..."
    create_env_file
    docker-compose down
    docker-compose build
    docker-compose up -d
    echo "✅ Development deployment complete!"
    echo "📋 Services:"
    echo "   - Rasa Main Server: http://localhost:5005"
    echo "   - Rasa Actions Server: http://localhost:5055"
}

# Function to deploy in production mode
deploy_prod() {
    echo "🏭 Deploying in production mode..."
    create_env_file
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.prod.yml build
    docker-compose -f docker-compose.prod.yml up -d
    echo "✅ Production deployment complete!"
    echo "📋 Services:"
    echo "   - Rasa Main Server: http://localhost:5005"
    echo "   - Rasa Actions Server: http://localhost:5055"
}

# Function to show status
show_status() {
    echo "📊 Service Status:"
    docker-compose ps
}

# Function to show logs
show_logs() {
    echo "📝 Service Logs:"
    docker-compose logs -f
}

# Function to stop services
stop_services() {
    echo "🛑 Stopping services..."
    docker-compose down
    echo "✅ Services stopped."
}

# Main menu
case "$1" in
    "dev"|"development")
        deploy_dev
        ;;
    "prod"|"production")
        deploy_prod
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "stop")
        stop_services
        ;;
    *)
        echo "Usage: $0 {dev|prod|status|logs|stop}"
        echo ""
        echo "Commands:"
        echo "  dev        - Deploy in development mode"
        echo "  prod       - Deploy in production mode"
        echo "  status     - Show service status"
        echo "  logs       - Show service logs"
        echo "  stop       - Stop all services"
        exit 1
        ;;
esac 