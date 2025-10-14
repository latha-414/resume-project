pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        APP_NAME   = 'student'
        AWS_CREDENTIALS = 'aws-creds'
        GITHUB_CREDS = 'github-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: "${GITHUB_CREDS}", url: 'https://github.com/latha-414/resume-project.git'
            }
        }

        stage('Build & Push Backend Docker') {
            steps {
                script {
                    docker.image('amazonlinux:2').inside('-v /var/run/docker.sock:/var/run/docker.sock') {
                        sh '''
                        yum install -y docker awscli
                        service docker start
                        BACKEND_ECR=$(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text)
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $BACKEND_ECR
                        docker build -t $BACKEND_ECR:latest ./backend
                        docker push $BACKEND_ECR:latest
                        '''
                    }
                }
            }
        }

        stage('Build & Push Frontend Docker') {
            steps {
                script {
                    docker.image('amazonlinux:2').inside('-v /var/run/docker.sock:/var/run/docker.sock') {
                        sh '''
                        yum install -y docker awscli
                        service docker start
                        FRONTEND_ECR=$(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text)
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $FRONTEND_ECR
                        docker build -t $FRONTEND_ECR:latest ./frontend
                        docker push $FRONTEND_ECR:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                script {
                    docker.image('hashicorp/terraform:1.7.6').inside {
                        dir('terraform') {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }
    }
}
