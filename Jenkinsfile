pipeline {
    agent any
    tools {
        nodejs '23.7.0'
    }
    stages {
        stage('installing dependencies') {
            steps {
                sh 'npm install --no-audit'
            }
        }
    }
}
