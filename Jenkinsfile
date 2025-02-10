pipeline {
    agent any
    tools {
        nodejs '23.7.0'
    }
    environment {
        MONGO_URI = "mongodb+srv://supercluster.d83jj.mongodb.net/superData"
        MONGO_USERNAME = credentials('mongodb-user')
        MONGO_PASSWORD = credentials('mongodb-password')
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REGION = 'ap-south-1'
        ECR_REPO = 'solar-system'
        FULL_IMAGE_NAME = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
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

        stage('Unit Test') {
            steps {
                script {
                    try {
                        sh 'npm test'
                    } catch (err) {
                        junit testResults: 'test-results.xml'
                        throw err
                    }
                }
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
                sh "docker build -t ${FULL_IMAGE_NAME}:${GIT_COMMIT} ."
            }
        }

        stage('Trivy vulnerability scan') {
            steps {
                script {
                    // Scan for LOW, MEDIUM, HIGH vulnerabilities
                    sh 'trivy image ${FULL_IMAGE_NAME}:${GIT_COMMIT} --severity LOW,MEDIUM,HIGH --exit-code 0 --quiet --format json -o trivy-MEDIUM-report.json'
                    
                    // Scan for CRITICAL vulnerabilities
                    sh 'trivy image ${FULL_IMAGE_NAME}:${GIT_COMMIT} --severity CRITICAL --exit-code 1 --quiet --format json -o trivy-CRITICAL-report.json'
                }
            }
            post {
                always {
                    sh '''
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

        stage('Push docker image to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                docker push ${FULL_IMAGE_NAME}:${GIT_COMMIT}
                '''
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

            // Clean up Docker images
            sh '''
                docker rmi solar:${GIT_COMMIT} || true
                docker rmi ${FULL_IMAGE_NAME}:${GIT_COMMIT} || true
                docker system prune -f || true
            '''
            
            // Clean workspace
            cleanWs()
        }
    }
}
  