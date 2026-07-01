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
        
        // stage('Build Test Image') {
        //     steps {
        //         sh '''
        //             docker build -f Dockerfile.test -t myapp-test .
        //         '''
        //     }
        // }

        stage('Unit Test + Coverage') {
            steps {
                // sh '''
                // docker run --rm myapp-test sh -c "
                //     sh scripts/test.sh
                // "
                // '''
                sh 'docker compose run -f docker-compose.test.yaml --rm test'
            }
        }

                    sh scripts/check_coverage.sh
    //    
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