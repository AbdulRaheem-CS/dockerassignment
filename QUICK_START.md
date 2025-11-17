# Quick Start Guide - Local Testing

## Test Part-I Locally (Before AWS Deployment)

### 1. Build Docker Image
```bash
docker build -t corereputation-app:latest .
```

### 2. Run with Docker Compose
```bash
docker-compose up -d
```

### 3. Check Status
```bash
docker-compose ps
docker-compose logs -f
```

### 4. Access Application
- Web App: http://localhost:3000
- MongoDB: localhost:27017

### 5. Test Data Persistence
```bash
# Stop containers
docker-compose down

# Start again
docker-compose up -d

# Data should still be there!
```

### 6. Push to Docker Hub
```bash
docker login
docker tag corereputation-app:latest YOUR_USERNAME/corereputation-app:latest
docker push YOUR_USERNAME/corereputation-app:latest
```

---

## Test Part-II Locally (Jenkins Setup)

### 1. Update GitHub Repository
```bash
git add .
git commit -m "Add Docker and Jenkins configuration"
git push origin main
```

### 2. Test Jenkins Compose File
```bash
docker-compose -f docker-compose-jenkins.yml up -d
```

### 3. Access Application
- Web App: http://localhost:3001
- MongoDB: localhost:27018

---

## Environment Variables to Update

Before deployment, update these in your docker-compose files:

```yaml
# In docker-compose.yml and docker-compose-jenkins.yml
environment:
  - MONGODB_URI=mongodb://admin:YOUR_PASSWORD@mongodb:27017/corereputation?authSource=admin
  - JWT_SECRET=YOUR_SECURE_JWT_SECRET
  - NEXTAUTH_SECRET=YOUR_SECURE_NEXTAUTH_SECRET
  - NEXTAUTH_URL=http://YOUR_EC2_IP:3000  # or 3001 for Jenkins
```

---

## Files Created for Assignment

### Part-I Files:
- `Dockerfile` - Multi-stage Docker build
- `docker-compose.yml` - Orchestrates webapp + MongoDB with persistent volumes
- `.dockerignore` - Excludes unnecessary files
- `next.config.mjs` - Updated with standalone output

### Part-II Files:
- `Jenkinsfile` - CI/CD pipeline script
- `docker-compose-jenkins.yml` - Modified compose with volume mounting
- `DOCKER_JENKINS_DEPLOYMENT.md` - Complete deployment guide

---

## Common Issues & Quick Fixes

### Port Already in Use
```bash
# Find process
lsof -i :3000
# Kill it
kill -9 <PID>
```

### Docker Permission Denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Clear Everything and Start Fresh
```bash
# Stop all containers
docker-compose down
docker-compose -f docker-compose-jenkins.yml down

# Remove volumes (WARNING: deletes data)
docker volume prune -f

# Remove images
docker image prune -a -f

# Rebuild
docker-compose up -d --build
```

---

## Assignment Checklist

### Before Submission:
- [ ] Test Docker build locally
- [ ] Test docker-compose locally
- [ ] Push image to Docker Hub
- [ ] Deploy on AWS EC2
- [ ] Install Jenkins on EC2
- [ ] Configure Jenkins pipeline
- [ ] Test pipeline execution
- [ ] Take screenshots of all steps
- [ ] Document any issues and solutions

### Screenshots Needed:
1. docker build output
2. docker images list
3. Docker Hub repository page
4. docker-compose ps output
5. Application running in browser (Part-I)
6. Volume persistence test
7. Jenkins dashboard
8. Pipeline execution stages
9. Pipeline console output
10. Application running on port 3001 (Part-II)
11. EC2 instance details
12. Security group rules

Good luck! 🚀
