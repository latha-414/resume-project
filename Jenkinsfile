pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    ECR_BACKEND = '<aws_account_id>.dkr.ecr.ap-south-1.amazonaws.com/student-backend'
    ECR_FRONTEND = '<aws_account_id>.dkr.ecr.ap-south-1.amazonaws.com/student-frontend'
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/latha-414/resume-project.git'
      }
    }

    stage('Login to ECR') {
      steps {
        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_BACKEND'
        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_FRONTEND'
      }
    }

    stage('Build & Push Backend Docker') {
      steps {
        sh 'docker build -t $ECR_BACKEND:latest ./backend'
        sh 'docker push $ECR_BACKEND:latest'
      }
    }

    stage('Build & Push Frontend Docker') {
      steps {
        sh 'docker build -t $ECR_FRONTEND:latest ./frontend'
        sh 'docker push $ECR_FRONTEND:latest'
      }
    }
  }
}
