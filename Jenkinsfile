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
        stage('Build Test Image') {
            steps {
                sh '''
                    docker run --rm \
                    -v "$WORKSPACE:/app" \
                    -w /app \
                    myapp-test \
                    sh scripts/test.sh
                '''
            }
        }

        stage('Unit Test + Coverage') {
            steps {
                sh '''
                docker run --rm \
                    -v $PWD:/app \
                    -w /app \
                    myapp-test \
                    sh scripts/test.sh
                '''
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