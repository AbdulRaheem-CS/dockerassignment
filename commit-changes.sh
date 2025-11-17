#!/bin/bash

# Git Commit and Push Script for Assignment
# This script helps you commit all Docker and Jenkins files to GitHub

echo "🚀 Preparing to commit Docker and Jenkins configuration..."
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
fi

# Add all new files
echo "📦 Adding files to git..."
git add Dockerfile
git add docker-compose.yml
git add docker-compose-jenkins.yml
git add Jenkinsfile
git add .dockerignore
git add next.config.mjs
git add package.json
git add DOCKER_JENKINS_DEPLOYMENT.md
git add QUICK_START.md
git add ASSIGNMENT_SUMMARY.md

# Show what will be committed
echo ""
echo "📋 Files to be committed:"
git status --short

echo ""
read -p "Do you want to commit these changes? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Commit with message
    git commit -m "Add Docker and Jenkins configuration for containerized deployment

    Part-I:
    - Dockerfile with multi-stage build
    - docker-compose.yml with MongoDB and persistent volumes
    - .dockerignore file
    
    Part-II:
    - Jenkinsfile with CI/CD pipeline
    - docker-compose-jenkins.yml with volume mounting
    - Updated next.config.mjs for standalone build
    
    Documentation:
    - Complete deployment guide
    - Quick start reference
    - Assignment summary"
    
    echo ""
    echo "✅ Changes committed successfully!"
    echo ""
    
    # Check if remote exists
    if git remote | grep -q origin; then
        echo "🔄 Remote 'origin' exists"
        read -p "Do you want to push to GitHub? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push -u origin main
            echo "✅ Pushed to GitHub successfully!"
        fi
    else
        echo "⚠️  No remote repository configured."
        echo "To add a remote, run:"
        echo "  git remote add origin https://github.com/david-clinger/coreReputation.git"
        echo "  git push -u origin main"
    fi
else
    echo "❌ Commit cancelled."
fi

echo ""
echo "📝 Next steps:"
echo "1. Push to GitHub (if not done already)"
echo "2. Follow DOCKER_JENKINS_DEPLOYMENT.md for deployment"
echo "3. Start with Part-I, then move to Part-II"
echo ""
echo "Good luck! 🎉"
