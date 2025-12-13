pipeline {
    agent any

    environment {
        IMAGE_NAME = "vision-ui-dashboard"
        PORT = "${PORT ?: 8081}"
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
                sh """
                docker build -t $IMAGE_NAME:${GIT_TAG_NAME ?: 'latest'} .
                docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME:${GIT_TAG_NAME ?: 'latest'}
                """
            }
        }

        stage('Smoke Test') {
            steps {
                sh 'bash smoke-test.sh'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/**', fingerprint: true
            }
        }

        stage('Cleanup') {
            steps {
                sh """
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true
                """
            }
        }
    }
}
