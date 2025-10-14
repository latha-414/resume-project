pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_BACKEND = '<AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/student-backend'
        ECR_FRONTEND = '<AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/student-frontend'
    }

    stages {
        stage('Checkout') {
            steps { git url: 'https://github.com/latha-414/resume-project.git', branch: 'main' }
        }

        stage('Build & Push Backend Docker') {
            steps {
                sh '''
                docker build -t $ECR_BACKEND:latest ./backend
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_BACKEND
                docker push $ECR_BACKEND:latest
                '''
            }
        }

        stage('Build & Push Frontend Docker') {
            steps {
                sh '''
                docker build -t $ECR_FRONTEND:latest ./frontend
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_FRONTEND
                docker push $ECR_FRONTEND:latest
                '''
            }
        }

        stage('Deploy with Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
