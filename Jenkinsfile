pipeline {
    agent {
        docker {
            image 'amazonlinux:2' // base image
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        AWS_REGION = 'ap-south-1'
        APP_NAME   = 'student'
        AWS_CREDENTIALS = 'aws-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github-creds', url: 'https://github.com/latha-414/resume-project.git'
            }
        }

        stage('Build & Push Backend Docker') {
            steps {
                sh """
                yum install -y docker awscli
                service docker start
                $(aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text))
                docker build -t $(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text):latest ./backend
                docker push $(aws ecr describe-repositories --repository-names ${APP_NAME}-backend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text):latest
                """
            }
        }

        stage('Build & Push Frontend Docker') {
            steps {
                sh """
                $(aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text))
                docker build -t $(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text):latest ./frontend
                docker push $(aws ecr describe-repositories --repository-names ${APP_NAME}-frontend --region ${AWS_REGION} --query 'repositories[0].repositoryUri' --output text):latest
                """
            }
        }

        stage('Deploy with Terraform') {
            steps {
                dir('terraform') {
                    sh 'yum install -y unzip wget && wget https://releases.hashicorp.com/terraform/1.7.6/terraform_1.7.6_linux_amd64.zip && unzip terraform_1.7.6_linux_amd64.zip && mv terraform /usr/local/bin/'
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
