pipeline {
    agent any
    environment {
        DOCKER_CONFIG = '/tmp/.docker'
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '442042522885.dkr.ecr.us-east-1.amazonaws.com'
        registryCreds = 'ecr:us-east-1:awscreds'
    }

    stages {
        stage('Docker Test') {
            steps {
                script {
                    sh 'docker --version'
                    sh 'docker ps'
                }
            }
        }

        stage('Build and Test Java Services') {
            parallel {
                stage('API Gateway') {
                    steps {
                        dir('apigateway') {
                            sh 'chmod +x mvnw'
                            sh './mvnw clean package -DskipTests'
                        }
                    }
                }
                stage('Booking Service') {
                    steps {
                        dir('bookingservice') {
                            sh 'chmod +x mvnw'
                            sh './mvnw clean package -DskipTests'
                        }
                    }
                }
                stage('Inventory Service') {
                    steps {
                        dir('inventoryservice') {
                            sh 'chmod +x mvnw'
                            sh './mvnw clean package -DskipTests'
                        }
                    }
                }
                stage('Order Service') {
                    steps {
                        dir('orderservice') {
                            sh 'chmod +x mvnw'
                            sh './mvnw clean package -DskipTests'
                        }
                    }
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build API Gateway Image') {
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            sh "docker build -t ${ECR_REGISTRY}/apigateway:${BUILD_NUMBER} ./apigateway"
                            sh "docker tag ${ECR_REGISTRY}/apigateway:${BUILD_NUMBER} ${ECR_REGISTRY}/apigateway:latest"
                        }
                    }
                }
                stage('Build Booking Service Image') {
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            sh "docker build -t ${ECR_REGISTRY}/bookingservice:${BUILD_NUMBER} ./bookingservice"
                            sh "docker tag ${ECR_REGISTRY}/bookingservice:${BUILD_NUMBER} ${ECR_REGISTRY}/bookingservice:latest"
                        }
                    }
                }
                stage('Build Inventory Service Image') {
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            sh "docker build -t ${ECR_REGISTRY}/inventoryservice:${BUILD_NUMBER} ./inventoryservice"
                            sh "docker tag ${ECR_REGISTRY}/inventoryservice:${BUILD_NUMBER} ${ECR_REGISTRY}/inventoryservice:latest"
                        }
                    }
                }
                stage('Build Order Service Image') {
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            sh "docker build -t ${ECR_REGISTRY}/orderservice:${BUILD_NUMBER} ./orderservice"
                            sh "docker tag ${ECR_REGISTRY}/orderservice:${BUILD_NUMBER} ${ECR_REGISTRY}/orderservice:latest"
                        }
                    }
                }
            }
        }

        stage('Push Docker Images to ECR') {
            steps {
                script {
                    // Login to ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                    // Push all images
                    sh "docker push ${ECR_REGISTRY}/apigateway:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/apigateway:latest"

                    sh "docker push ${ECR_REGISTRY}/bookingservice:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/bookingservice:latest"

                    sh "docker push ${ECR_REGISTRY}/inventoryservice:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/inventoryservice:latest"

                    sh "docker push ${ECR_REGISTRY}/orderservice:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/orderservice:latest"
                }
            }
        }
    }
}
