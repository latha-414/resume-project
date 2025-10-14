pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    ECR_REPO = 'your-ecr-repo-url'
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/latha-414/resume-project.git'
      }
    }

    stage('Login to ECR') {
      steps {
        sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $ECR_REPO:latest .'
      }
    }

    stage('Push Image to ECR') {
      steps {
        sh 'docker push $ECR_REPO:latest'
      }
    }
  }
}
