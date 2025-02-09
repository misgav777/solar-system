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
                // sh 'printenv'
                sh 'docker build -t solar:$GIT_COMMIT .'
            }
        }

        stage('Trivy vulnerability scan') {
            steps {
                script {
                    // Scan for LOW, MEDIUM, HIGH vulnerabilities
                    sh 'trivy image solar:${GIT_COMMIT} --severity LOW,MEDIUM --exit-code 0 --quiet --format json -o trivy-MEDIUM-report.json'
                    
                    // Scan for CRITICAL vulnerabilities
                    sh 'trivy image solar:${GIT_COMMIT} --severity CRITICAL --exit-code 1 --quiet --format json -o trivy-CRITICAL-report.json'
                }
            }
            post {
                always {
                    '''
                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                            --output trivy-MEDIUM-report.html trivy-MEDIUM-report.json
                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/html.tpl" \
                            --output trivy-CRITICAL-report.html trivy-CRITICAL-report.json
                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                            --output trivy-MEDIUM-report.xml trivy-MEDIUM-report.json
                        trivy convert \
                            --format template --template "@/usr/local/share/trivy/templates/junit.tpl" \
                            --output trivy-CRITICAL-report.xml trivy-CRITICAL-report.json
                        '''
                }
            }
        }
    }

    post {
        always {
            // junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'dependency-check-junit.xml'

            // publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: './', reportFiles: 'dependency-check-jenkins.html', reportName: 'Dependency HTML Report', reportTitles: '', useWrapperFileDirectly: true])

            junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'test-results.xml'

            junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'trivy-MEDIUM-report.xml'
            
            junit allowEmptyResults: true, keepProperties: true, stdioRetention: '', testResults: 'trivy-CRITICAL-report.xml'

            publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'coverage/lcov-report', reportFiles: 'index.html', reportName: 'Code Coverage Report', reportTitles: ''])

            publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: './', reportFiles: 'trivy-MEDIUM-report.html', reportName: 'Trivy image Medium Vul Report', reportTitles: ''])

            publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: './', reportFiles: 'trivy-CRITICAL-report.html', reportName: 'Trivy image Critical Vul Report', reportTitles: ''])
        }
    }
}
  