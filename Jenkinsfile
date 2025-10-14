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
                        // Get AWS Account ID
                        def accountId = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
                        
                        // Login to ECR
                        sh """
                            aws ecr get-login-password --region $AWS_REGION | \
                            docker login --username AWS --password-stdin ${accountId}.dkr.ecr.$AWS_REGION.amazonaws.com
                        """

                        // Define local ECR URLs
                        def ecrBackend  = "${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-backend"
                        def ecrFrontend = "${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-frontend"

                        // Build & Push Backend
                        dir('backend') {
                            def commitId = sh(script: "git rev-parse HEAD", returnStdout: true).trim().take(7)
                            sh """
                                docker build -t ${APP_NAME}-backend:$commitId .
                                docker tag ${APP_NAME}-backend:$commitId $ecrBackend:$commitId
                                docker push $ecrBackend:$commitId
                            """
                        }

                        // Build & Push Frontend
                        dir('frontend') {
                            def commitId = sh(script: "git rev-parse HEAD", returnStdout: true).trim().take(7)
                            sh """
                                docker build -t ${APP_NAME}-frontend:$commitId .
                                docker tag ${APP_NAME}-frontend:$commitId $ecrFrontend:$commitId
                                docker push $ecrFrontend:$commitId
                            """
                        }
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
