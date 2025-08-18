pipeline {
    agent any

    options {
        skipDefaultCheckout()
        timestamps()
    }

    environment {
        // Simple local tags only for now; no AWS/ECR until configured
        BUILD_TAG_BASE = "local"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Verify Docker') {
            steps {
                sh 'docker --version'
                sh 'docker ps -q >/dev/null || true'
            }
        }

        stage('Build JARs') {
            parallel {
                stage('apigateway') {
                    steps { dir('apigateway'){ sh './mvnw -B clean package -DskipTests' } }
                }
                stage('bookingservice') {
                    steps { dir('bookingservice'){ sh './mvnw -B clean package -DskipTests' } }
                }
                stage('inventoryservice') {
                    steps { dir('inventoryservice'){ sh './mvnw -B clean package -DskipTests' } }
                }
                stage('orderservice') {
                    steps { dir('orderservice'){ sh './mvnw -B clean package -DskipTests' } }
                }
            }
        }

        stage('Build Docker Images (local only)') {
            parallel {
                stage('apigateway image') {
                    steps { dir('apigateway'){ sh 'docker build -t apigateway:${BUILD_NUMBER} .' } }
                }
                stage('bookingservice image') {
                    steps { dir('bookingservice'){ sh 'docker build -t bookingservice:${BUILD_NUMBER} .' } }
                }
                stage('inventoryservice image') {
                    steps { dir('inventoryservice'){ sh 'docker build -t inventoryservice:${BUILD_NUMBER} .' } }
                }
                stage('orderservice image') {
                    steps { dir('orderservice'){ sh 'docker build -t orderservice:${BUILD_NUMBER} .' } }
                }
            }
        }

        // Future stage placeholder for pushing to ECR once credentials & repos exist
        // stage('Push to ECR') { when { expression { return false } } steps { echo 'Configure AWS/ECR first.' } }
    }

    post {
        success {
            archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
        }
        always { cleanWs() }
    }
}
