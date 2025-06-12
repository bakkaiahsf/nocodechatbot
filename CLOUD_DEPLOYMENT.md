# 🌩️ Rasa Cloud Deployment Guide

This guide provides step-by-step instructions to deploy your Rasa main server and actions server to the cloud.

## 📋 **Prerequisites**

- ✅ Local Docker setup working (completed)
- ✅ Docker Hub account (free)
- ✅ Cloud platform account (AWS, Google Cloud, Azure, or Render)
- ✅ OpenAI API key

## 🗂️ **Deployment Options**

1. [Docker Hub + Render (Easiest)](#option-1-docker-hub--render-easiest)
2. [AWS ECS (Production-ready)](#option-2-aws-ecs-production-ready)
3. [Google Cloud Run (Serverless)](#option-3-google-cloud-run-serverless)
4. [Azure Container Instances](#option-4-azure-container-instances)

---

## **Option 1: Docker Hub + Render (Easiest)**

### **Step 1: Build and Push to Docker Hub**

1. **Create Docker Hub Repository:**
   ```bash
   # Login to Docker Hub
   docker login
   ```

2. **Tag and Push Images:**
   ```powershell
   # Build and tag images
   docker build -f Dockerfile.rasa-main -t your-username/rasa-main:latest .
   docker build -f Dockerfile.rasa-actions -t your-username/rasa-actions:latest .
   
   # Push to Docker Hub
   docker push your-username/rasa-main:latest
   docker push your-username/rasa-actions:latest
   ```

### **Step 2: Deploy to Render**

1. **Go to [Render.com](https://render.com)** and sign up
2. **Create New Web Service** for each container:

#### **Deploy Rasa Actions Server:**
- **Name:** `rasa-actions`
- **Source:** Docker Hub
- **Image URL:** `your-username/rasa-actions:latest`
- **Port:** `5055`
- **Environment Variables:**
  ```
  OPENAI_API_KEY=your_openai_api_key_here
  ```
- **Health Check Path:** `/health`

#### **Deploy Rasa Main Server:**
- **Name:** `rasa-main`
- **Source:** Docker Hub  
- **Image URL:** `your-username/rasa-main:latest`
- **Port:** `5005`
- **Environment Variables:**
  ```
  ACTION_ENDPOINT_URL=https://rasa-actions-xxxx.onrender.com/webhook
  ```
  (Replace with your actual Render actions service URL)

### **Step 3: Test Deployment**
```bash
# Test the deployed bot
curl -X POST https://rasa-main-xxxx.onrender.com/webhooks/rest/webhook \
  -H "Content-Type: application/json" \
  -d '{"sender": "test", "message": "hello"}'
```

---

## **Option 2: AWS ECS (Production-ready)**

### **Step 1: Setup AWS CLI**
```bash
# Install AWS CLI
# Configure credentials
aws configure
```

### **Step 2: Create ECR Repositories**
```bash
# Create repositories
aws ecr create-repository --repository-name rasa-main --region us-east-1
aws ecr create-repository --repository-name rasa-actions --region us-east-1

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### **Step 3: Build and Push Images**
```bash
# Build images
docker build -f Dockerfile.rasa-main -t rasa-main .
docker build -f Dockerfile.rasa-actions -t rasa-actions .

# Tag for ECR
docker tag rasa-main:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/rasa-main:latest
docker tag rasa-actions:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/rasa-actions:latest

# Push to ECR
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/rasa-main:latest
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/rasa-actions:latest
```

### **Step 4: Create ECS Task Definition**
Create `aws-task-definition.json`:
```json
{
  "family": "rasa-cluster",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "rasa-actions",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/rasa-actions:latest",
      "portMappings": [{"containerPort": 5055}],
      "environment": [
        {"name": "OPENAI_API_KEY", "value": "your_api_key_here"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/rasa",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    },
    {
      "name": "rasa-main",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/rasa-main:latest",
      "portMappings": [{"containerPort": 5005}],
      "environment": [
        {"name": "ACTION_ENDPOINT_URL", "value": "http://localhost:5055/webhook"}
      ],
      "dependsOn": [
        {"containerName": "rasa-actions", "condition": "START"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/rasa",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### **Step 5: Deploy to ECS**
```bash
# Register task definition
aws ecs register-task-definition --cli-input-json file://aws-task-definition.json

# Create cluster
aws ecs create-cluster --cluster-name rasa-cluster

# Create service
aws ecs create-service --cluster rasa-cluster --service-name rasa-service --task-definition rasa-cluster --desired-count 1 --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}"
```

---

## **Option 3: Google Cloud Run (Serverless)**

### **Step 1: Setup Google Cloud**
```bash
# Install Google Cloud SDK
# Login and set project
gcloud auth login
gcloud config set project your-project-id
```

### **Step 2: Build and Push to Container Registry**
```bash
# Configure Docker for GCR
gcloud auth configure-docker

# Build images
docker build -f Dockerfile.rasa-actions -t gcr.io/your-project-id/rasa-actions .
docker build -f Dockerfile.rasa-main -t gcr.io/your-project-id/rasa-main .

# Push images
docker push gcr.io/your-project-id/rasa-actions
docker push gcr.io/your-project-id/rasa-main
```

### **Step 3: Deploy to Cloud Run**
```bash
# Deploy actions server
gcloud run deploy rasa-actions \
  --image gcr.io/your-project-id/rasa-actions \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 5055 \
  --set-env-vars OPENAI_API_KEY=your_api_key_here

# Get actions server URL
ACTIONS_URL=$(gcloud run services describe rasa-actions --platform managed --region us-central1 --format 'value(status.url)')

# Deploy main server
gcloud run deploy rasa-main \
  --image gcr.io/your-project-id/rasa-main \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 5005 \
  --set-env-vars ACTION_ENDPOINT_URL=$ACTIONS_URL/webhook
```

---

## **Option 4: Azure Container Instances**

### **Step 1: Setup Azure CLI**
```bash
# Login to Azure
az login
```

### **Step 2: Create Container Registry**
```bash
# Create resource group
az group create --name rasa-rg --location eastus

# Create container registry
az acr create --resource-group rasa-rg --name rasaregistry --sku Basic --admin-enabled true
```

### **Step 3: Build and Push Images**
```bash
# Login to registry
az acr login --name rasaregistry

# Build and push
az acr build --registry rasaregistry --image rasa-actions:latest -f Dockerfile.rasa-actions .
az acr build --registry rasaregistry --image rasa-main:latest -f Dockerfile.rasa-main .
```

### **Step 4: Deploy Containers**
```bash
# Get registry credentials
ACR_SERVER=$(az acr show --name rasaregistry --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name rasaregistry --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name rasaregistry --query passwords[0].value --output tsv)

# Deploy actions container
az container create \
  --resource-group rasa-rg \
  --name rasa-actions \
  --image $ACR_SERVER/rasa-actions:latest \
  --registry-login-server $ACR_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --dns-name-label rasa-actions-unique \
  --ports 5055 \
  --environment-variables OPENAI_API_KEY=your_api_key_here

# Deploy main container
az container create \
  --resource-group rasa-rg \
  --name rasa-main \
  --image $ACR_SERVER/rasa-main:latest \
  --registry-login-server $ACR_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --dns-name-label rasa-main-unique \
  --ports 5005 \
  --environment-variables ACTION_ENDPOINT_URL=http://rasa-actions-unique.eastus.azurecontainer.io:5055/webhook
```

---

## 🔧 **Cloud Deployment Scripts**

### **Docker Hub Push Script** 