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

        stage('Verify') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl get pods -n estate
                    kubectl get svc -n estate
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f || true'
        }
    }
}