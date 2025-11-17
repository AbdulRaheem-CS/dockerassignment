pipeline {
    agent any
    
    environment {
        DOCKER_COMPOSE_FILE = 'docker-compose-jenkins.yml'
        GIT_REPO = 'https://github.com/david-clinger/coreReputation.git'
        GIT_BRANCH = 'main'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Fetching code from GitHub...'
                git branch: "${GIT_BRANCH}", 
                    url: "${GIT_REPO}"
            }
        }
        
        stage('Verify Files') {
            steps {
                echo 'Verifying required files...'
                sh '''
                    echo "Checking for docker-compose file..."
                    ls -la ${DOCKER_COMPOSE_FILE}
                    
                    echo "Checking for package.json..."
                    ls -la package.json
                    
                    echo "Current directory contents:"
                    ls -la
                '''
            }
        }
        
        stage('Stop Previous Containers') {
            steps {
                echo 'Stopping and removing previous containers...'
                sh '''
                    docker-compose -f ${DOCKER_COMPOSE_FILE} down || true
                '''
            }
        }
        
        stage('Build and Deploy') {
            steps {
                echo 'Building and deploying containerized application...'
                sh '''
                    # Pull latest images
                    docker-compose -f ${DOCKER_COMPOSE_FILE} pull
                    
                    # Build and start containers in detached mode
                    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --build
                    
                    # Wait for services to be healthy
                    echo "Waiting for services to start..."
                    sleep 15
                    
                    # Check container status
                    docker-compose -f ${DOCKER_COMPOSE_FILE} ps
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                sh '''
                    # Check if containers are running
                    docker-compose -f ${DOCKER_COMPOSE_FILE} ps
                    
                    # Check MongoDB health
                    docker exec corereputation-mongodb-jenkins mongosh --eval "db.adminCommand('ping')" || true
                    
                    # Check web app logs
                    echo "Web application logs:"
                    docker logs --tail 50 corereputation-webapp-jenkins || true
                '''
            }
        }
        
        stage('Display Access Info') {
            steps {
                echo 'Deployment completed successfully!'
                sh '''
                    echo "=========================================="
                    echo "Application deployed successfully!"
                    echo "Web Application: http://localhost:3001"
                    echo "MongoDB: localhost:27018"
                    echo "=========================================="
                    echo "Running containers:"
                    docker ps --filter "name=corereputation"
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo 'Containerized web application is now running.'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
            sh '''
                echo "Container logs:"
                docker-compose -f ${DOCKER_COMPOSE_FILE} logs --tail 100 || true
            '''
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
