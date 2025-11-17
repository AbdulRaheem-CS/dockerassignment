# Docker & Jenkins Deployment Guide
## Cloud Computing Assignment - Parts I & II

---

## 📋 Table of Contents
1. [Part-I: Containerized Deployment](#part-i-containerized-deployment)
2. [Part-II: Jenkins CI/CD Pipeline](#part-ii-jenkins-cicd-pipeline)
3. [Troubleshooting](#troubleshooting)

---

# Part-I: Containerized Deployment with Docker

## 🎯 Objectives
- Deploy web application in Docker containers
- Use MongoDB as persistent database
- Deploy on AWS EC2 instance

## 📁 Files Created
- `Dockerfile` - Multi-stage Docker image for Next.js app
- `docker-compose.yml` - Orchestrates webapp and MongoDB containers
- `.dockerignore` - Excludes unnecessary files from Docker build

---

## 🚀 Part-I: Step-by-Step Deployment

### Step 1: Set Up AWS EC2 Instance

#### 1.1 Launch EC2 Instance
```bash
# Login to AWS Console
# Navigate to EC2 Dashboard
# Click "Launch Instance"

# Configuration:
- Name: CoreReputation-Docker-Server
- AMI: Ubuntu Server 22.04 LTS (Free tier eligible)
- Instance Type: t2.medium (minimum recommended for Docker)
- Key Pair: Create new or use existing
- Security Group: Create new with following rules:
  * SSH (22) - Your IP
  * HTTP (80) - Anywhere
  * Custom TCP (3000) - Anywhere (for web app)
  * Custom TCP (27017) - Your IP (for MongoDB)
```

#### 1.2 Connect to EC2 Instance
```bash
# Download your key pair and set permissions
chmod 400 your-key.pem

# Connect via SSH
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
```

### Step 2: Install Docker on EC2

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

### Step 3: Transfer Application to EC2

```bash
# Option A: Using Git (Recommended)
cd ~
git clone https://github.com/david-clinger/coreReputation.git
cd coreReputation

# Option B: Using SCP (if not using Git)
# On your local machine:
scp -i your-key.pem -r /Users/abdulraheem/Desktop/Freelancing/getaiiq ubuntu@<ec2-ip>:~/coreReputation
```

### Step 4: Build Docker Image

```bash
# Navigate to project directory
cd ~/coreReputation

# Build the Docker image
docker build -t corereputation-app:latest .

# Verify image was created
docker images | grep corereputation
```

### Step 5: Push Image to Docker Hub

```bash
# Login to Docker Hub
docker login
# Enter your Docker Hub username and password

# Tag the image
docker tag corereputation-app:latest <your-dockerhub-username>/corereputation-app:latest

# Push to Docker Hub
docker push <your-dockerhub-username>/corereputation-app:latest

# Verify on Docker Hub
# Visit: https://hub.docker.com/r/<your-username>/corereputation-app
```

### Step 6: Deploy with Docker Compose

```bash
# Update docker-compose.yml with your environment variables
nano docker-compose.yml
# Update MongoDB credentials and other environment variables

# Start the containers
docker-compose up -d

# Verify containers are running
docker-compose ps

# Check logs
docker-compose logs -f webapp
docker-compose logs -f mongodb
```

### Step 7: Verify Deployment

```bash
# Check container status
docker ps

# Test web application
curl http://localhost:3000

# Test from browser
# Visit: http://<your-ec2-public-ip>:3000

# Check MongoDB connection
docker exec -it corereputation-mongodb mongosh -u admin -p securepassword123
# In mongo shell:
show dbs
use corereputation
show collections
exit
```

### Step 8: Verify Persistent Volume

```bash
# Check volumes
docker volume ls
docker volume inspect corereputation_mongodb_data

# Test data persistence
# 1. Add some data to your application
# 2. Stop containers
docker-compose down

# 3. Start containers again
docker-compose up -d

# 4. Verify data still exists
# Data should persist because of mounted volumes
```

---

## ✅ Part-I Checklist
- [x] Dockerfile created with multi-stage build
- [x] Docker image built and pushed to Docker Hub
- [x] docker-compose.yml with MongoDB service
- [x] Persistent volumes attached to MongoDB
- [x] Application deployed on AWS EC2
- [x] Application accessible via browser

---

# Part-II: Jenkins CI/CD Pipeline

## 🎯 Objectives
- Set up Jenkins on AWS EC2
- Create automated build pipeline
- Integrate Git and Docker with Jenkins

## 📁 Files Created
- `Jenkinsfile` - Pipeline script for automated builds
- `docker-compose-jenkins.yml` - Modified compose file with volume mounting

---

## 🚀 Part-II: Step-by-Step Setup

### Step 1: Install Jenkins on EC2

```bash
# Update system
sudo apt update

# Install Java (required for Jenkins)
sudo apt install -y openjdk-11-jdk

# Verify Java installation
java -version

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check status
sudo systemctl status jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 2: Configure Jenkins

#### 2.1 Access Jenkins Web Interface
```
1. Open browser and go to: http://<your-ec2-public-ip>:8080
2. Enter the initial admin password
3. Install suggested plugins
4. Create admin user
5. Configure Jenkins URL
```

#### 2.2 Install Required Plugins
```
Jenkins Dashboard → Manage Jenkins → Manage Plugins → Available

Install these plugins:
1. Git Plugin (should be pre-installed)
2. Pipeline Plugin (should be pre-installed)
3. Docker Pipeline Plugin
4. Docker Plugin

Restart Jenkins after installation:
sudo systemctl restart jenkins
```

### Step 3: Add Jenkins to Docker Group

```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Verify jenkins can run docker
sudo -u jenkins docker ps
```

### Step 4: Configure Docker in Jenkins

```bash
# Ensure Jenkins can access Docker socket
sudo chmod 666 /var/run/docker.sock

# Or for permanent solution, add to jenkins service
sudo nano /lib/systemd/system/jenkins.service
# Add after [Service]:
# SupplementaryGroups=docker

sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

### Step 5: Push Code to GitHub

```bash
# On your local machine
cd /Users/abdulraheem/Desktop/Freelancing/getaiiq

# Initialize git if not already done
git init

# Add all files
git add .

# Commit changes
git commit -m "Add Docker and Jenkins configuration"

# Add remote repository
git remote add origin https://github.com/david-clinger/coreReputation.git

# Push to GitHub
git push -u origin main
```

### Step 6: Create Jenkins Pipeline Job

#### 6.1 Create New Pipeline Job
```
1. Jenkins Dashboard → New Item
2. Enter name: "CoreReputation-Pipeline"
3. Select "Pipeline"
4. Click OK
```

#### 6.2 Configure Pipeline
```
General Section:
- Description: "Automated build pipeline for CoreReputation web app"
- ✓ GitHub project: https://github.com/david-clinger/coreReputation

Build Triggers:
- ✓ Poll SCM
  Schedule: H/5 * * * * (checks every 5 minutes)
  OR
- ✓ GitHub hook trigger for GITScm polling (for webhooks)

Pipeline Section:
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: https://github.com/david-clinger/coreReputation.git
- Branch: */main
- Script Path: Jenkinsfile

Save the configuration
```

### Step 7: Run the Pipeline

```
1. Go to your pipeline job
2. Click "Build Now"
3. Watch the pipeline execute through stages:
   - Checkout Code
   - Verify Files
   - Stop Previous Containers
   - Build and Deploy
   - Health Check
   - Display Access Info

4. Check Console Output for logs
5. View Blue Ocean visualization (optional)
```

### Step 8: Verify Deployment

```bash
# Check running containers
docker ps

# Check pipeline-deployed application
curl http://localhost:3001

# View logs
docker logs corereputation-webapp-jenkins
docker logs corereputation-mongodb-jenkins

# Test from browser
# Visit: http://<your-ec2-public-ip>:3001
```

### Step 9: Configure GitHub Webhook (Optional)

```
1. Go to GitHub repository
2. Settings → Webhooks → Add webhook
3. Payload URL: http://<your-ec2-public-ip>:8080/github-webhook/
4. Content type: application/json
5. Events: Just the push event
6. Active: ✓
7. Add webhook

Now Jenkins will automatically build on every push!
```

---

## ✅ Part-II Checklist
- [x] Jenkins installed on AWS EC2
- [x] Git, Pipeline, and Docker Pipeline plugins installed
- [x] Jenkins can access Docker
- [x] Code pushed to GitHub repository
- [x] Jenkinsfile created with proper stages
- [x] Pipeline job configured in Jenkins
- [x] Pipeline successfully builds and deploys
- [x] Application uses volume mounting (not Dockerfile)
- [x] Different ports and container names used

---

## 🔍 Key Differences: Part-I vs Part-II

| Aspect | Part-I | Part-II |
|--------|--------|---------|
| **Docker Image** | Built from Dockerfile | Uses base Node image |
| **Code Deployment** | Copied into image | Mounted as volume |
| **Ports** | 3000, 27017 | 3001, 27018 |
| **Container Names** | corereputation-webapp/mongodb | corereputation-webapp/mongodb-jenkins |
| **Compose File** | docker-compose.yml | docker-compose-jenkins.yml |
| **Deployment** | Manual | Automated via Jenkins |

---

## 🛠️ Troubleshooting

### Docker Issues

**Problem: Permission denied while trying to connect to Docker daemon**
```bash
sudo usermod -aG docker $USER
newgrp docker
# Or restart your session
```

**Problem: Port already in use**
```bash
# Find process using the port
sudo lsof -i :3000

# Kill the process
sudo kill -9 <PID>

# Or change port in docker-compose.yml
```

**Problem: Container exits immediately**
```bash
# Check logs
docker logs <container-name>

# Run interactively to debug
docker run -it corereputation-app:latest sh
```

### Jenkins Issues

**Problem: Jenkins cannot access Docker**
```bash
# Add jenkins to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Check socket permissions
sudo chmod 666 /var/run/docker.sock
```

**Problem: Pipeline fails at Git checkout**
```bash
# Verify Git plugin is installed
# Check repository URL is correct
# Ensure branch name is correct (main vs master)
```

**Problem: Out of memory**
```bash
# Increase Jenkins memory
sudo nano /etc/default/jenkins
# Add: JAVA_ARGS="-Xmx2048m"
sudo systemctl restart jenkins
```

### MongoDB Issues

**Problem: Cannot connect to MongoDB**
```bash
# Check if container is running
docker ps | grep mongodb

# Check logs
docker logs corereputation-mongodb

# Verify credentials in environment variables
docker exec -it corereputation-mongodb mongosh -u admin -p securepassword123
```

### Application Issues

**Problem: Application not accessible from browser**
```bash
# Check EC2 Security Group rules
# Ensure port 3000/3001 is open

# Check if app is running
docker logs corereputation-webapp

# Test locally first
curl http://localhost:3000
```

---

## 📊 Useful Commands

### Docker Commands
```bash
# View all containers
docker ps -a

# View images
docker images

# View volumes
docker volume ls

# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune

# View logs
docker logs <container-name>
docker logs -f <container-name>  # Follow logs

# Execute command in container
docker exec -it <container-name> sh

# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -aq)
```

### Docker Compose Commands
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild and start
docker-compose up -d --build

# Scale services
docker-compose up -d --scale webapp=3

# Check status
docker-compose ps
```

### Jenkins Commands
```bash
# Start Jenkins
sudo systemctl start jenkins

# Stop Jenkins
sudo systemctl stop jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Check status
sudo systemctl status jenkins

# View logs
sudo journalctl -u jenkins -f
```

---

## 🎓 Assignment Submission Checklist

### Part-I
- [ ] Dockerfile with multi-stage build
- [ ] Docker image pushed to Docker Hub
- [ ] docker-compose.yml with MongoDB
- [ ] Persistent volume configuration
- [ ] Application deployed on AWS EC2
- [ ] Screenshots of:
  - Running containers (docker ps)
  - Application in browser
  - Docker Hub repository
  - Volume persistence test

### Part-II
- [ ] Jenkins installed and configured
- [ ] Required plugins installed (Git, Pipeline, Docker Pipeline)
- [ ] Code in GitHub repository
- [ ] Jenkinsfile with all stages
- [ ] docker-compose-jenkins.yml with volume mounting
- [ ] Pipeline job configured
- [ ] Successful pipeline execution
- [ ] Screenshots of:
  - Jenkins dashboard
  - Pipeline stages
  - Console output
  - Running containers from Jenkins build
  - Application running on port 3001

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

---

## 🎉 Congratulations!

You have successfully:
✅ Containerized a web application with Docker
✅ Deployed it on AWS EC2 with persistent storage
✅ Set up Jenkins CI/CD pipeline
✅ Automated the build and deployment process

Good luck with your assignment! 🚀
