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

        stage('Build & Push Backend Docker') {
            steps {
                script {
                    sh """
                    docker run --rm -v \$PWD:/workspace -w /workspace amazon/aws-cli:latest \
                    bash -c '
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin \$(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query repositories[0].repositoryUri --output text)
                        docker build -t \$(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query repositories[0].repositoryUri --output text):latest ./backend
                        docker push \$(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query repositories[0].repositoryUri --output text):latest
                    '
                    """
                }
            }
        }

        stage('Build & Push Frontend Docker') {
            steps {
                script {
                    sh """
                    docker run --rm -v \$PWD:/workspace -w /workspace amazon/aws-cli:latest \
                    bash -c '
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin \$(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query repositories[0].repositoryUri --output text)
                        docker build -t \$(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query repositories[0].repositoryUri --output text):latest ./frontend
                        docker push \$(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query repositories[0].repositoryUri --output text):latest
                    '
                    """
                }
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
