pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        APP_NAME   = 'student'
        AWS_CREDS  = 'aws-creds'
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
                    sh '''
                    docker run --rm -v /var/lib/jenkins/workspace/resume:/workspace -w /workspace amazon/aws-cli:latest bash -c "
                    BACKEND_ECR=\$(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text)
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin \$BACKEND_ECR
                    docker build -t \$BACKEND_ECR:latest ./backend
                    docker push \$BACKEND_ECR:latest
                    "
                    '''
                }
            }
        }

        stage('Build & Push Frontend Docker') {
            steps {
                script {
                    sh '''
                    docker run --rm -v /var/lib/jenkins/workspace/resume:/workspace -w /workspace amazon/aws-cli:latest bash -c "
                    FRONTEND_ECR=\$(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text)
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin \$FRONTEND_ECR
                    docker build -t \$FRONTEND_ECR:latest ./frontend
                    docker push \$FRONTEND_ECR:latest
                    "
                    '''
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                script {
                    sh '''
                    docker run --rm -v /var/lib/jenkins/workspace/resume/terraform:/workspace -w /workspace hashicorp/terraform:1.7.6 bash -c "
                    terraform init
                    terraform apply -auto-approve
                    "
                    '''
                }
            }
        }
    }
}
