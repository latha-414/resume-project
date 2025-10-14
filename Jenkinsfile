pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'    // Change if needed
        APP_NAME   = 'myapp'        // Change to your app name
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login to ECR') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh '''
                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        docker login --username AWS --password $(aws ecr get-login-password --region $AWS_REGION) $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                        echo "Logged into ECR"
                    '''
                }
            }
        }

        stage('Build & Push Backend') {
            steps {
                dir('backend') {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh '''
                            AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                            docker build -t ${APP_NAME}-backend .
                            docker tag ${APP_NAME}-backend $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-backend:latest
                            docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-backend:latest
                        '''
                    }
                }
            }
        }

        stage('Build & Push Frontend') {
            steps {
                dir('frontend') {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh '''
                            AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                            docker build -t ${APP_NAME}-frontend .
                            docker tag ${APP_NAME}-frontend $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-frontend:latest
                            docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${APP_NAME}-frontend:latest
                        '''
                    }
                }
            }
        }

        stage('Update ECS Services') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh '''
                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        aws ecs update-service --cluster ${APP_NAME}-cluster --service ${APP_NAME}-backend-service --force-new-deployment --region $AWS_REGION
                        aws ecs update-service --cluster ${APP_NAME}-cluster --service ${APP_NAME}-frontend-service --force-new-deployment --region $AWS_REGION
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker images...'
            sh 'docker system prune -f'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
