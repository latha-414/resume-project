pipeline {
    agent any

    environment {
        AWS_REGION      = 'ap-south-1'                     // change if needed
        AWS_ACCOUNT_ID  = credentials('aws-creds')    // Jenkins credentials ID for AWS
        APP_NAME        = 'student-app'
        BACKEND_IMAGE   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-backend"
        FRONTEND_IMAGE  = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-frontend"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/latha-414/resume-project.git'
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                """
            }
        }

        stage('Build & Push Backend Image') {
            steps {
                dir('backend') {
                    script {
                        def backendTag = "${APP_NAME}-backend:${GIT_COMMIT.take(7)}"
                        sh """
                            docker build -t $backendTag .
                            docker tag $backendTag $BACKEND_IMAGE:$backendTag
                            docker push $BACKEND_IMAGE:$backendTag
                        """
                    }
                }
            }
        }

        stage('Build & Push Frontend Image') {
            steps {
                dir('frontend') {
                    script {
                        def frontendTag = "${APP_NAME}-frontend:${GIT_COMMIT.take(7)}"
                        sh """
                            docker build -t $frontendTag .
                            docker tag $frontendTag $FRONTEND_IMAGE:$frontendTag
                            docker push $FRONTEND_IMAGE:$frontendTag
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Docker images built and pushed to ECR successfully!'
        }
        failure {
            echo 'Build or push failed.'
        }
    }
}
