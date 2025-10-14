pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        APP_NAME   = 'student-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/latha-414/resume-project.git'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    script {
                        // Get AWS account ID dynamically
                        def accountId = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()

                        // Login to ECR
                        sh """
                            aws ecr get-login-password --region $AWS_REGION | \
                            docker login --username AWS --password-stdin ${accountId}.dkr.ecr.$AWS_REGION.amazonaws.com
                        """

                        // Save ECR URLs to env variables for later stages
                        env.ECR_BACKEND  = "${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-backend"
                        env.ECR_FRONTEND = "${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-frontend"
                    }
                }
            }
        }

        stage('Build & Push Backend Image') {
            steps {
                dir('backend') {
                    script {
                        // Get commit hash
                        def commitId = sh(script: "git rev-parse HEAD", returnStdout: true).trim().take(7)
                        def backendTag = "${APP_NAME}-backend:${commitId}"

                        sh """
                            docker build -t $backendTag .
                            docker tag $backendTag $ECR_BACKEND:$commitId
                            docker push $ECR_BACKEND:$commitId
                        """
                    }
                }
            }
        }

        stage('Build & Push Frontend Image') {
            steps {
                dir('frontend') {
                    script {
                        // Get commit hash
                        def commitId = sh(script: "git rev-parse HEAD", returnStdout: true).trim().take(7)
                        def frontendTag = "${APP_NAME}-frontend:${commitId}"

                        sh """
                            docker build -t $frontendTag .
                            docker tag $frontendTag $ECR_FRONTEND:$commitId
                            docker push $ECR_FRONTEND:$commitId
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Docker images built and pushed successfully!'
        }
        failure {
            echo 'Build or push failed.'
        }
    }
}
