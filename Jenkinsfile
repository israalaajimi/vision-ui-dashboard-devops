pipeline {
    agent any

    environment {
        IMAGE_NAME = "vision-ui-dashboard"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup') {
            steps {
                sh 'node -v'
                sh 'npm -v'
            }
        }

        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }

        stage('Docker Build & Run') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
                sh 'docker run -d -p 8081:80 --name dashboard $IMAGE_NAME || true'
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                curl -s http://localhost:8081 | grep "<title>" && echo PASSED || exit 1
                '''
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/**', fingerprint: true
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker stop dashboard || true'
                sh 'docker rm dashboard || true'
            }
        }
    }
}
