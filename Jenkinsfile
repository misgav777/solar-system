pipeline {
    agent any
    tools {
        nodejs '23.7.0'
    }
    environment {
        MONGO_URI = "mongodb+srv://supercluster.d83jj.mongodb.net/superData"
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

                        junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'dependency-check-junit.xml'

                        publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: './', reportFiles: 'dependency-check-jenkins.html', 
                        reportName: 'Dependency HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                    }    
                }
            }
        }

        stage('Unit Test') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'mongodb-credentials', passwordVariable: 'MONGO_PASSWORD', usernameVariable: 'MONGO_USERNAME')]) {
                    sh 'npm test'
                }
                junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'test-results.xml'
            }
        }
    }
}
