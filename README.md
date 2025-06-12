# Rasa Chatbot Deployment

This project contains a Rasa chatbot with separate Docker containers for the main server and actions server.

## Architecture

- **Rasa Main Server**: Handles NLP processing, dialogue management, and serves the API
- **Rasa Actions Server**: Executes custom actions including OpenAI GPT integration

## Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 1.29+)
- OpenAI API Key

## Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd nocode-chatbot
```

### 2. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
# Copy from existing local env file
cp .env_local .env
```

Or create manually:
```env
OPENAI_API_KEY=your_openai_api_key_here
ACTION_ENDPOINT_URL=http://rasa-actions:5055/webhook
ENVIRONMENT=development
```

### 3. Deploy Using Script (Recommended)

Make the deployment script executable:
```bash
chmod +x deploy.sh
```

Deploy in development mode:
```bash
./deploy.sh dev
```

Deploy in production mode:
```bash
./deploy.sh prod
```

### 4. Manual Deployment (Alternative)

#### Development Mode
```bash
docker-compose up -d --build
```

#### Production Mode
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

## Service Access

After deployment, the services will be available at:

- **Rasa Main Server**: http://localhost:5005
- **Rasa Actions Server**: http://localhost:5055
- **Health Check**: http://localhost:5005/health

## Testing the Bot

### REST API
```bash
curl -X POST http://localhost:5005/webhooks/rest/webhook \
  -H "Content-Type: application/json" \
  -d '{"sender": "test", "message": "hello"}'
```

### Web Interface
Open http://localhost:5005 in your browser to access the Rasa UI.

## Management Commands

### Check Service Status
```bash
./deploy.sh status
# or
docker-compose ps
```

### View Logs
```bash
./deploy.sh logs
# or
docker-compose logs -f
```

### Stop Services
```bash
./deploy.sh stop
# or
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

## Development

### Training the Model
The model is automatically trained when the main server container starts. To manually train:

```bash
# Enter the main server container
docker exec -it rasa-main bash

# Train the model
rasa train

# Exit the container
exit
```

### Updating Actions
1. Modify files in the `actions/` directory
2. Restart the actions server:
```bash
docker-compose restart rasa-actions
```

### Adding New Training Data
1. Update files in the `data/` directory
2. Restart the main server to retrain:
```bash
docker-compose restart rasa-main
```

## File Structure

```
nocode-chatbot/
├── actions/                    # Custom actions
│   ├── actions.py             # Main actions file
│   └── __pycache__/
├── data/                      # Training data
├── models/                    # Trained models
├── config.yml                 # Rasa configuration
├── domain.yml                 # Bot domain definition
├── endpoints.yml              # Endpoint configuration
├── requirements.txt           # Python dependencies
├── Dockerfile.rasa-main       # Main server Docker image
├── Dockerfile.rasa-actions    # Actions server Docker image
├── docker-compose.yml         # Development deployment
├── docker-compose.prod.yml    # Production deployment
├── deploy.sh                  # Deployment script
└── README.md                  # This file
```

## Troubleshooting

### Environment Variable Error
If you see: `RasaException: Error when trying to expand the environment variables in '${ACTION_ENDPOINT_URL}'`

**Solution**: Ensure your `.env` file contains:
```env
ACTION_ENDPOINT_URL=http://rasa-actions:5055/webhook
```

### OpenAI API Error
If actions fail with OpenAI errors:

1. Check your `.env` file has the correct `OPENAI_API_KEY`
2. Restart the actions server: `docker-compose restart rasa-actions`

### Port Conflicts
If ports 5005 or 5055 are already in use:

1. Stop conflicting services
2. Or modify ports in `docker-compose.yml`:
```yaml
ports:
  - "5006:5005"  # Change external port
```

### Container Health Issues
Check container logs:
```bash
docker-compose logs rasa-main
docker-compose logs rasa-actions
```

### Model Training Issues
If the model fails to train:

1. Check training data in `data/` directory
2. Verify `config.yml` and `domain.yml` are valid
3. Check logs: `docker-compose logs rasa-main`

## Production Deployment

For production deployment:

1. Use `docker-compose.prod.yml`
2. Set environment variables securely
3. Configure reverse proxy (nginx/Apache)
4. Enable HTTPS
5. Set up monitoring and logging
6. Configure database persistence if needed

### Example Nginx Configuration
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5005;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Docker logs
3. Verify environment variables
4. Check Rasa documentation: https://rasa.com/docs/ 