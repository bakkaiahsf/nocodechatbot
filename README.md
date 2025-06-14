# Rasa Chatbot Deployment Guide

## Local Development

### Prerequisites
- Docker and Docker Compose installed
- Git

### Running Locally
1. Clone the repository
2. Set your OpenAI API key in an `.env` file:
   ```
   OPENAI_API_KEY=your_api_key_here
   ```
3. Start the services:
   ```
   docker-compose up
   ```
4. Access the chatbot at http://localhost:5005

## Handling Models for Deployment

### Option 1: Train and Commit Models (Recommended)
1. Train the model locally:
   ```
   docker-compose run --rm rasa-main rasa train
   ```
2. Commit the trained models to your repository:
   ```
   git add models/*.tar.gz
   git commit -m "Add trained models for deployment"
   git push
   ```

### Option 2: Train on First Startup
If you don't commit pre-trained models, the Dockerfile is configured to train a model on first startup. However, this:
- May fail on Render's free tier due to memory limitations
- Will significantly increase startup time
- Is not recommended for production

## Render Deployment

### Option 1: Deploy with Blueprint (Recommended)
1. Fork this repository to your GitHub account
2. Sign up for [Render](https://render.com)
3. Create a new "Blueprint" instance and connect your forked repository
4. Render will automatically use the `render.yaml` configuration

### Option 2: Manual Deployment
1. Fork this repository to your GitHub account
2. Sign up for [Render](https://render.com)
3. Create a new "Web Service"
4. Connect your GitHub repository
5. Configure as follows:
   - **Name:** `rasa-chatbot`
   - **Environment:** `Docker`
   - **Dockerfile Path:** `Dockerfile.render`
   - **Environment Variables:**
     - `OPENAI_API_KEY`: Your OpenAI API key
   - **Health Check Path:** `/`
   - **Port:** `8000`

## Important Notes
- The Render deployment uses pre-trained models to avoid memory issues
- The free tier has limited resources, so we've combined both servers into one container
- Make sure to commit your trained models to the repository before deploying

## API Endpoints
- Main Rasa API: `/webhooks/rest/webhook` (POST)
- Health Check: `/health` (GET)

## Testing the Deployment
```bash
curl -X POST https://your-render-url.onrender.com/webhooks/rest/webhook \
  -H "Content-Type: application/json" \
  -d '{"sender": "test_user", "message": "hello"}'
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