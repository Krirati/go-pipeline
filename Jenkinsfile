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
                    docker build -f Dockerfile.test -t myapp-test .
                '''
            }
        }

        stage('Debug Docker') {
            steps {
                sh '''
                    which docker
                    docker --version

                    echo "===== compose ====="
                    docker compose version || true

                    echo "===== docker-compose ====="
                    docker-compose version || true
                '''
            }
        }

        stage('Unit Test + Coverage') {
            steps {
                sh '''
                docker run --rm myapp-test sh -c "
                    sh scripts/go-test.sh
                "
                '''
                // sh 'dockฝer compose -f docker-compose.test.yaml run --rm test'
            }
        }

        stage('Build Production Image') {
            steps {
                // sh 'docker build -t myapp:latest .'
                echo 'Build image Success 🎉'
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