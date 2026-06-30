pipeline {
    agent any
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout SCM') {
            steps {
                echo 'Checkout source code'
                checkout scm
            }
        }
        stage('Debug') {
            steps {
                sh '''
                    pwd
                    ls -la
                    ls -R
                '''
            }
        }
        stage('Build Test Image') {
            steps {
                sh '''
                    docker build -f Dockerfile.test -t myapp-test .
                '''
            }
        }

        stage('Unit Test + Coverage') {
            stage('Unit Test + Coverage') {
                steps {
                    sh '''
                    docker run --rm \
                    -v "$WORKSPACE:/app" \
                    -w /app \
                    myapp-test \
                    sh -c "pwd && ls -la && ls -la scripts && cat scripts/test.sh"
                    '''
                }
            }
        }

        stage('Validate Coverage') {
            steps {
                sh './scripts/check_coverage.sh'
            }
        }
        stage('Build Production Image') {
            steps {
                sh 'docker build -t myapp:latest .'
            }
        }
    }
    post {
        always {
            echo 'Cleaning workspace'
            cleanWs()
            sh 'docker rmi myapp-test || true'
        }

        success {
            echo 'Pipeline Success 🎉'
        }

        failure {
            echo 'Pipeline Failed ❌'
        }
    }
}