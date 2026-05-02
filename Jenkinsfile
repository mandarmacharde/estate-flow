pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    environment {
        DOCKER_USERNAME = 'mandarmacharde'
        IMAGE_PREFIX = "${DOCKER_USERNAME}/estate-flow"
        BUILD_VERSION = "${BUILD_NUMBER}"
        GIT_REPO = 'https://github.com/mandarmacharde/estate-flow.git'
        EC2_IP = '3.91.245.51'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Backend') {
                    steps {
                        sh '''
                        docker build -t ${IMAGE_PREFIX}-backend:${BUILD_VERSION} ./backend
                        '''
                    }
                }
                stage('Frontend') {
                    steps {
                        sh '''
                        docker build -t ${IMAGE_PREFIX}-frontend:${BUILD_VERSION} ./frontend
                        '''
                    }
                }
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin

                    docker push ${IMAGE_PREFIX}-backend:${BUILD_VERSION}
                    docker push ${IMAGE_PREFIX}-frontend:${BUILD_VERSION}

                    docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            parallel {

                stage('Deploy to EC2') {
                    steps {
                        withCredentials([sshUserPrivateKey(
                            credentialsId: 'ec2-key',
                            keyFileVariable: 'KEY'
                        )]) {
                            sh '''
                            ssh -o StrictHostKeyChecking=no -i $KEY ubuntu@${EC2_IP} "

                                echo '🚀 Deploying to EC2...'

                                docker pull ${IMAGE_PREFIX}-backend:${BUILD_VERSION}
                                docker pull ${IMAGE_PREFIX}-frontend:${BUILD_VERSION}

                                docker network create estate-net || true

                                docker rm -f backend || true
                                docker rm -f frontend || true

                                docker run -d \
                                  --name backend \
                                  --network estate-net \
                                  -p 5000:5000 \
                                  -e DB_HOST=mysql \
                                  -e DB_USER=estate_user \
                                  -e DB_PASSWORD=estate_password \
                                  -e DB_NAME=estateflow \
                                  ${IMAGE_PREFIX}-backend:${BUILD_VERSION}

                                docker run -d \
                                  --name frontend \
                                  --network estate-net \
                                  -p 80:8080 \
                                  ${IMAGE_PREFIX}-frontend:${BUILD_VERSION}

                                echo '✅ EC2 Deploy Done'
                            "
                            '''
                        }
                    }
                }

                stage('Deploy to Kubernetes') {
                    steps {
                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            sh '''
                            kubectl set image deployment/backend-deployment \
                              backend=${IMAGE_PREFIX}-backend:${BUILD_VERSION} -n estate

                            kubectl set image deployment/frontend-deployment \
                              frontend=${IMAGE_PREFIX}-frontend:${BUILD_VERSION} -n estate

                            kubectl rollout status deployment/backend-deployment -n estate
                            kubectl rollout status deployment/frontend-deployment -n estate
                            '''
                        }
                    }
                }
            }
        }

        stage('Verify') {
            steps {
                sh '''
                echo "🌐 Checking EC2 backend..."
                curl -f http://${EC2_IP}/api/health

                echo "☸️ Checking Kubernetes..."
                kubectl get pods -n estate
                '''
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f || true'
        }
    }
}