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

        stage('Scanning dependencies') {
            parallel {
                stage('NPM dependencies Audit') {
                    steps {
                        sh 'npm audit --audit-level=critical'
                        sh 'echo $?' // print the exit code
                    }
                }

                stage('OWASP Dependency-Check') {
                    steps {
                        dependencyCheck additionalArguments: '''
                            --scan \'./\'
                            --format \'ALL\'
                            --out \'./\'
                            --prettyPrint
                        ''', odcInstallation: 'OWASP-Dependency-Check-10'
                    }    
                }
            }
        }
    }
}
