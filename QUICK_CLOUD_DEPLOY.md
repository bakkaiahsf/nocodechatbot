# 🚀 Quick Cloud Deployment Guide

**Fastest way to deploy your Rasa chatbot to the cloud in under 30 minutes!**

## 📋 **Step-by-Step Cloud Deployment**

### **Step 1: Prepare Docker Hub Account**

1. **Sign up at [Docker Hub](https://hub.docker.com)** (free account)
2. **Login to Docker Hub from your terminal:**
   ```powershell
   docker login
   ```
   Enter your Docker Hub username and password

### **Step 2: Push Images to Docker Hub**

1. **Run the automated deployment script:**
   ```powershell
   .\deploy-cloud.ps1 -DockerHubUsername "your-dockerhub-username"
   ```
   
   **OR manually build and push:**
   ```powershell
   # Build images
   docker build -f Dockerfile.rasa-actions -t your-username/rasa-actions:latest .
   docker build -f Dockerfile.rasa-main -t your-username/rasa-main:latest .
   
   # Push to Docker Hub
   docker push your-username/rasa-actions:latest
   docker push your-username/rasa-main:latest
   ```

### **Step 3: Deploy to Render**

1. **Go to [Render.com](https://render.com)** and create account
2. **Click "New +" → "Web Service"**

#### **Deploy Actions Server First:**

3. **Fill in the form:**
   - **Name:** `rasa-actions`
   - **Source:** Select "Deploy from Docker Hub"
   - **Image URL:** `your-username/rasa-actions:latest`
   - **Port:** `5055`
   - **Instance Type:** Free (for testing) or Starter (for production)

4. **Add Environment Variables:**
   - Click "Environment Variables"
   - Add: `OPENAI_API_KEY` = `your_openai_api_key_here`

5. **Advanced Settings:**
   - **Health Check Path:** `/health`
   - **Auto-Deploy:** Yes

6. **Click "Create Web Service"**
7. **Wait for deployment** (5-10 minutes)
8. **Copy the service URL** (e.g., `https://rasa-actions-xyz.onrender.com`)

#### **Deploy Main Server Second:**

9. **Click "New +" → "Web Service" again**
10. **Fill in the form:**
    - **Name:** `rasa-main`
    - **Source:** Select "Deploy from Docker Hub"  
    - **Image URL:** `your-username/rasa-main:latest`
    - **Port:** `5005`
    - **Instance Type:** Free (for testing) or Starter (for production)

11. **Add Environment Variables:**
    - Click "Environment Variables"
    - Add: `ACTION_ENDPOINT_URL` = `https://rasa-actions-xyz.onrender.com/webhook`
    - (Replace with your actual actions server URL from step 8)

12. **Click "Create Web Service"**
13. **Wait for deployment** (5-10 minutes)

### **Step 4: Test Your Cloud Deployment**

1. **Get your main server URL** from Render dashboard
2. **Test the bot:**
   ```powershell
   # Test basic endpoint
   Invoke-RestMethod -Uri "https://rasa-main-xyz.onrender.com/webhooks/rest/webhook" -Method POST -Body '{"sender": "test", "message": "hello"}' -ContentType "application/json"
   ```

3. **Test OpenAI integration:**
   ```powershell
   # Test GPT fallback
   Invoke-RestMethod -Uri "https://rasa-main-xyz.onrender.com/webhooks/rest/webhook" -Method POST -Body '{"sender": "test", "message": "What is artificial intelligence?"}' -ContentType "application/json"
   ```

4. **Check health:**
   ```powershell
   # Check actions server
   Invoke-RestMethod -Uri "https://rasa-actions-xyz.onrender.com/health" -Method GET
   ```

## 🎯 **Expected Results**

✅ **Actions Server Health Check:**
```json
{
  "status": "ok"
}
```

✅ **Bot Response Test:**
```json
{
  "recipient_id": "test",
  "text": "Hey! How are you?"
}
```

✅ **OpenAI Integration Test:**
```json
{
  "recipient_id": "test", 
  "text": "Artificial intelligence (AI) refers to..."
}
```

## 🔧 **Post-Deployment Steps**

### **Monitor Your Services:**
1. **Render Dashboard:** Monitor logs, metrics, and health
2. **Set up alerts** for service downtime
3. **Configure custom domain** (optional)

### **Optimize for Production:**
1. **Upgrade to paid plans** for better performance
2. **Enable auto-scaling** if needed
3. **Set up SSL certificates** (Render provides free SSL)
4. **Configure environment-specific variables**

### **Integration:**
1. **Use your bot URL** in web applications:
   ```javascript
   const botEndpoint = "https://rasa-main-xyz.onrender.com/webhooks/rest/webhook";
   ```

2. **Create a simple chat interface:**
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>My Rasa Bot</title>
   </head>
   <body>
       <div id="chat-container">
           <div id="messages"></div>
           <input type="text" id="user-input" placeholder="Type a message...">
           <button onclick="sendMessage()">Send</button>
       </div>
       
       <script>
           async function sendMessage() {
               const input = document.getElementById('user-input');
               const message = input.value;
               
               const response = await fetch('https://rasa-main-xyz.onrender.com/webhooks/rest/webhook', {
                   method: 'POST',
                   headers: { 'Content-Type': 'application/json' },
                   body: JSON.stringify({ sender: 'user', message: message })
               });
               
               const data = await response.json();
               // Display response...
           }
       </script>
   </body>
   </html>
   ```

## 🚨 **Troubleshooting**

### **Service Won't Start:**
- Check Docker Hub image names are correct
- Verify environment variables are set
- Check Render logs for error messages

### **Actions Server Connection Issues:**
- Ensure `ACTION_ENDPOINT_URL` points to the correct actions server URL
- Verify actions server is healthy (`/health` endpoint)
- Check network connectivity between services

### **OpenAI API Errors:**
- Verify `OPENAI_API_KEY` is correctly set
- Check OpenAI API usage limits
- Monitor actions server logs for detailed errors

### **Performance Issues:**
- Free tier has cold starts (30+ second delays)
- Upgrade to paid plans for production use
- Consider using Cloud Run or ECS for better performance

## 📊 **Cost Estimates**

### **Render Pricing:**
- **Free Tier:** $0/month (with limitations)
  - 750 hours/month
  - Cold starts after 15 minutes idle
  - Good for development/testing

- **Starter Plan:** $7/month per service
  - Always-on instances
  - No cold starts
  - Better for production

### **OpenAI API:**
- **GPT-3.5-turbo:** ~$0.0015 per 1K tokens
- **Typical chat message:** ~100-200 tokens
- **Estimated cost:** $0.15-0.30 per 1K messages

## 🎉 **Success!**

Your Rasa chatbot is now live in the cloud! 

**Next steps:**
- Share your bot URL with users
- Integrate with websites or apps
- Monitor usage and performance
- Scale up as needed

**Your Bot URLs:**
- **Main Bot:** `https://rasa-main-xyz.onrender.com/webhooks/rest/webhook`
- **Actions Server:** `https://rasa-actions-xyz.onrender.com/health`

Happy chatbotting! 🤖✨ 