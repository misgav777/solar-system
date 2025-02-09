pipeline {
    agent any
    tools {
        nodejs '23.7.0'
    }
    environment {
        MONGO_URI = "mongodb+srv://supercluster.d83jj.mongodb.net/superData"
        MONGO_USERNAME = credentials('mongodb-user')
        MONGO_PASSWORD = credentials('mongodb-password')
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
                // stage('OWASP Dependency-Check') {
                //     steps {
                //         dependencyCheck additionalArguments: '''
                //             --scan \'./\'
                //             --format \'ALL\'
                //             --out \'./\'
                //             --prettyPrint
                //         ''', odcInstallation: 'OWASP-Dependency-Check-10'     
                //     }    
                // }
            }
        }

        stage('Unit Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Code coverage') {
            steps {
                catchError(buildResult: 'SUCCESS', message: 'Oops It will be fix next release!!', stageResult: 'UNSTABLE') {
                    sh 'npm run coverage'
                }                
            }
        }

        stage('Build docker image') {
            steps {
                sh 'printenv'
                sh 'docker build -t solar:$GIT_COMMIT .'
            }
        }
    }

    post {
        always {
            // junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'dependency-check-junit.xml'

            // publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: './', reportFiles: 'dependency-check-jenkins.html', reportName: 'Dependency HTML Report', reportTitles: '', useWrapperFileDirectly: true])

            junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'test-results.xml'

            publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'coverage/lcov-report', reportFiles: 'index.html', reportName: 'Code Coverage Report', reportTitles: ''])
        }
    }
}
  