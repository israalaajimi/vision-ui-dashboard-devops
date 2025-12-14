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
                    
                    def TAG_NAME = bat(
                        script: "git describe --tags --exact-match",
                        returnStdout: true
                    ).trim()

                    echo "Building Docker image with tag: ${TAG_NAME}"

                    bat """
                    docker build -t %IMAGE_NAME%:${TAG_NAME} .
                    docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %IMAGE_NAME%:${TAG_NAME}
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
               
                bat 'smoke-test.bat'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/**', fingerprint: true
            }
        }

        stage('Cleanup') {
            steps {
                bat """
                docker stop %CONTAINER_NAME% || echo container not running
                docker rm %CONTAINER_NAME% || echo container not found
                """
            }
        }
    }
}

