pipeline {
    agent any
    tools {
        nodejs '23.7.0'
    }
    stages {
        stage('test-nodejs') {
            steps {
                '''
                echo "Testing NodeJS"
                node --version
                npm --version
                '''
            }
        }
    }
}
