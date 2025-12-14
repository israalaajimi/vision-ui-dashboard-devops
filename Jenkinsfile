pipeline {
    agent any

    environment {
        IMAGE_NAME = "vision-ui-dashboard"
        PORT = "8081"
        CONTAINER_NAME = "dashboard-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup') {
            steps {
                bat 'node -v'
                bat 'npm -v'
                
                // Test if Docker is available
                bat 'docker --version || echo Docker not found'
            }
        }

        stage('Build') {
            steps {
                bat 'npm install'
                bat 'npm run build'
            }
        }

        stage('Docker Build & Run') {
            steps {
                script {
                    // Get tag name - FIXED for Windows
                    def tagOutput = bat(
                        script: '@echo off && git describe --tags --abbrev=0 2>nul || echo latest',
                        returnStdout: true
                    ).trim()
                    
                    // Remove any extra characters
                    def TAG_NAME = tagOutput.replaceAll("[^a-zA-Z0-9._-]", "")
                    
                    if (TAG_NAME == "latest" || TAG_NAME.isEmpty()) {
                        TAG_NAME = "latest"
                    }
                    
                    echo "Building Docker image with tag: ${TAG_NAME}"

                    bat """
                    docker build -t %IMAGE_NAME%:${TAG_NAME} .
                    
                    docker stop %CONTAINER_NAME% 2>nul || echo No container to stop
                    docker rm %CONTAINER_NAME% 2>nul || echo No container to remove
                    
                    docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %IMAGE_NAME%:${TAG_NAME}
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    // Wait for container to start
                    bat 'timeout /t 10 /nobreak'
                    
                    // Run smoke test (Windows version)
                    bat '''
                    @echo off
                    curl -s -o nul -w "%%{http_code}" http://localhost:%PORT% > response.txt
                    set /p STATUS=<response.txt
                    if "%STATUS%"=="200" (
                        echo SMOKE TEST PASSED
                        exit /b 0
                    ) else (
                        echo SMOKE TEST FAILED - Status: %STATUS%
                        exit /b 1
                    )
                    '''
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/**/*', fingerprint: true
            }
        }

        stage('Cleanup') {
            steps {
                bat """
                docker stop %CONTAINER_NAME% 2>nul || echo Container not running
                docker rm %CONTAINER_NAME% 2>nul || echo Container not found
                """
            }
        }
    }
    
    post {
        always {
            // Clean workspace
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
