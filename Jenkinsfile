pipeline {
    agent any
    tools {
        nodejs '23.7.0'
    }
    stages {
        stage('test-nodejs') {
            steps {
                sh '''
                node --version
                npm --version
                '''
            }
        }
    }
}
