pipeline {
    agent none
    environment {
        DOCKER_CONFIG = '/tmp/.docker'
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '442042522885.dkr.ecr.us-east-1.amazonaws.com'
        registryCreds = 'ecr:us-east-1:awscreds'
    }

    stages {
        stage('Docker Test') {
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh 'docker ps'
            }
        }

        stage('Build and Test Java Services') {
            parallel {
                stage('API Gateway') {
                    agent {
                        docker {
                            image 'maven:3.8.4-openjdk-17'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        dir('apigateway') {
                            sh 'mvn clean test package -DskipTests'
                        }
                    }
                }
                stage('Booking Service') {
                    agent {
                        docker {
                            image 'maven:3.8.4-openjdk-17'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        dir('bookingservice') {
                            sh 'mvn clean test package -DskipTests'
                        }
                    }
                }
                stage('Inventory Service') {
                    agent {
                        docker {
                            image 'maven:3.8.4-openjdk-17'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        dir('inventoryservice') {
                            sh 'mvn clean test package -DskipTests'
                        }
                    }
                }
                stage('Order Service') {
                    agent {
                        docker {
                            image 'maven:3.8.4-openjdk-17'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        dir('orderservice') {
                            sh 'mvn clean test package -DskipTests'
                        }
                    }
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build API Gateway Image') {
                    agent {
                        docker {
                            image 'docker:latest'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            def apigatewayImage = docker.build("${ECR_REGISTRY}/apigateway:$BUILD_NUMBER", "./apigateway")
                            env.APIGATEWAY_IMAGE = "${ECR_REGISTRY}/apigateway:$BUILD_NUMBER"
                        }
                    }
                }
                stage('Build Booking Service Image') {
                    agent {
                        docker {
                            image 'docker:latest'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            def bookingImage = docker.build("${ECR_REGISTRY}/bookingservice:$BUILD_NUMBER", "./bookingservice")
                            env.BOOKING_IMAGE = "${ECR_REGISTRY}/bookingservice:$BUILD_NUMBER"
                        }
                    }
                }
                stage('Build Inventory Service Image') {
                    agent {
                        docker {
                            image 'docker:latest'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            def inventoryImage = docker.build("${ECR_REGISTRY}/inventoryservice:$BUILD_NUMBER", "./inventoryservice")
                            env.INVENTORY_IMAGE = "${ECR_REGISTRY}/inventoryservice:$BUILD_NUMBER"
                        }
                    }
                }
                stage('Build Order Service Image') {
                    agent {
                        docker {
                            image 'docker:latest'
                            args '-v /var/run/docker.sock:/var/run/docker.sock'
                        }
                    }
                    steps {
                        script {
                            sh 'mkdir -p /tmp/.docker'
                            def orderImage = docker.build("${ECR_REGISTRY}/orderservice:$BUILD_NUMBER", "./orderservice")
                            env.ORDER_IMAGE = "${ECR_REGISTRY}/orderservice:$BUILD_NUMBER"
                        }
                    }
                }
            }
        }

        stage('Push Docker Images to ECR') {
            agent {
                docker {
                    image 'docker:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    docker.withRegistry("https://${ECR_REGISTRY}", registryCreds) {
                        // Push all service images
                        docker.image("${ECR_REGISTRY}/apigateway:$BUILD_NUMBER").push("$BUILD_NUMBER")
                        docker.image("${ECR_REGISTRY}/apigateway:$BUILD_NUMBER").push('latest')

                        docker.image("${ECR_REGISTRY}/bookingservice:$BUILD_NUMBER").push("$BUILD_NUMBER")
                        docker.image("${ECR_REGISTRY}/bookingservice:$BUILD_NUMBER").push('latest')

                        docker.image("${ECR_REGISTRY}/inventoryservice:$BUILD_NUMBER").push("$BUILD_NUMBER")
                        docker.image("${ECR_REGISTRY}/inventoryservice:$BUILD_NUMBER").push('latest')

                        docker.image("${ECR_REGISTRY}/orderservice:$BUILD_NUMBER").push("$BUILD_NUMBER")
                        docker.image("${ECR_REGISTRY}/orderservice:$BUILD_NUMBER").push('latest')
                    }
                }
            }
        }
    }
}
