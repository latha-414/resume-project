pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        APP_NAME   = 'myapp'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set AWS Credentials') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials']]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        echo "Using AWS Account: $AWS_ACCOUNT_ID"
                    '''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    docker login --username AWS --password $(aws ecr get-login-password --region $AWS_REGION) $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Build & Push Backend') {
            steps {
                dir('backend') {
                    sh '''
                        docker build -t ${APP_NAME}-backend .
                        docker tag ${APP_NAME}-backend $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-backend:latest
                        docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-backend:latest
                    '''
                }
            }
        }

        stage('Build & Push Frontend') {
            steps {
                dir('frontend') {
                    sh '''
                        docker build -t ${APP_NAME}-frontend .
                        docker tag ${APP_NAME}-frontend $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-frontend:latest
                        docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-frontend:latest
                    '''
                }
            }
        }

        stage('Update ECS Services') {
            steps {
                sh '''
                    aws ecs update-service --cluster ${APP_NAME}-cluster --service ${APP_NAME}-backend-service --force-new-deployment --region $AWS_REGION
                    aws ecs update-service --cluster ${APP_NAME}-cluster --service ${APP_NAME}-frontend-service --force-new-deployment --region $AWS_REGION
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker images...'
            sh 'docker system prune -f'
        }
    }
}
