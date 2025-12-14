pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                bat 'dir'
            }
        }
        
        stage('Setup') {
            steps {
                bat 'node --version'
                bat 'docker --version'
            }
        }
        
        stage('Build') {
            steps {
                bat 'npm install --legacy-peer-deps'
            }
        }
        
       stage('Docker Build & Run') {
    steps {
        bat '''
            @echo off
            echo ===== DOCKER BUILD =====
            
            echo 1. Building image...
            docker build -t vision-ui-dashboard:latest -f Dockerfile .
            if %errorlevel% neq 0 (
                echo ERROR: Docker build failed!
                exit 1
            )
            
            echo 2. Stopping old container...
            docker stop dashboard-smoke 2>nul || echo "No old container"
            docker rm dashboard-smoke 2>nul || echo "No container to remove"
            
            echo 3. Running new container...
            docker run -d -p 3002:80 --name dashboard-smoke vision-ui-dashboard:latest
            if %errorlevel% neq 0 (
                echo ERROR: Docker run failed!
                exit 1
            )
            
            echo 4. Waiting 10 seconds...
            timeout /t 10 /nobreak
            
            echo 5. Container status:
            docker ps --filter "name=dashboard-smoke"
        '''
    }
}
        stage('Smoke Test') {
            steps {
                bat '''
                    @echo off
                    echo Testing application...
                    curl -f http://localhost:3002 || (
                        echo Smoke test FAILED!
                        exit 1
                    )
                    echo Smoke test PASSED!
                '''
            }
        }
        
        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/**/*'
                archiveArtifacts artifacts: 'docker-logs.txt'
            }
        }
        
        stage('Cleanup') {
            steps {
                bat '''
                    docker stop dashboard-smoke || echo "Container not running"
                    docker rm dashboard-smoke || echo "Container not found"
                    docker rmi vision-ui-dashboard:latest || echo "Image not found"
                '''
            }
        }
    }
    
    post {
        always {
            bat 'docker logs dashboard-smoke > docker-logs.txt 2>&1 || echo "No logs"'
        }
    }
}