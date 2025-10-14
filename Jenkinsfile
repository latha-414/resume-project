pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        APP_NAME   = 'student' // your app name
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/latha-414/resume-project.git'
            }
        }

        stage('Get ECR Repository URIs') {
            steps {
                script {
                    ECR_BACKEND = sh(
                        script: "aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text",
                        returnStdout: true
                    ).trim()

                    ECR_FRONTEND = sh(
                        script: "aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text",
                        returnStdout: true
                    ).trim()

                    echo "Backend ECR URI: ${ECR_BACKEND}"
                    echo "Frontend ECR URI: ${ECR_FRONTEND}"
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_BACKEND}"
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_FRONTEND}"
            }
        }

        stage('Build & Push Backend Docker') {
            steps {
                sh "docker build -t ${ECR_BACKEND}:latest ./backend"
                sh "docker push ${ECR_BACKEND}:latest"
            }
        }

        stage('Build & Push Frontend Docker') {
            steps {
                sh "docker build -t ${ECR_FRONTEND}:latest ./frontend"
                sh "docker push ${ECR_FRONTEND}:latest"
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
