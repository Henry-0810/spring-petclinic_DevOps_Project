pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Cleaning workspace and cloning repo...'
                deleteDir()
                git branch: 'main', url: 'https://github.com/Henry-0810/spring-petclinic_DevOps_Project.git'
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Building and testing the Spring Boot application...'
                sh 'mvn clean package'
                sh 'mvn test'
            }
        }

        stage('Code Quality Analysis - SonarCloud') {
            steps {
                echo 'Running SonarCloud Analysis...'
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                    mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=Henry-0810_spring-petclinic_DevOps_Project \
                        -Dsonar.organization=henry-0810 \
                        -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                    echo 'Building Docker image...'
                    sh '''
                    export DOCKER_BUILDKIT=0
                    docker build -t henry0810/spring-petclinic .
                    '''
                }
        }

        stage('Verify Docker Image') {
            steps {
                echo 'Checking Docker images before pushing...'
                sh 'docker images'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Docker image to registry...'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    sh '''
                    echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push henry0810/spring-petclinic
                    '''
                }
            }
        }
    }


    post {
        success {
            echo 'Build succeeded. Sending email and updating GitHub status...'

            // Email notification
            emailext(
                subject: "Jenkins Build SUCCESS",
                body: "The build completed successfully. Check Jenkins for more info.",
                to: "munli2002@gmail.com"
            )

            // GitHub status update
            withCredentials([string(credentialsId: 'github-credentials', variable: 'GITHUB_TOKEN')]) {
                sh '''
                curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
                     -H "Accept: application/vnd.github.v3+json" \
                     -d '{"state": "success", "description": "Jenkins Build Passed!", "context": "continuous-integration/jenkins"}' \
                     https://api.github.com/repos/henry-0810/spring-petclinic_DevOps_Project/statuses/$GIT_COMMIT
                '''
            }

            echo 'CI Passed. Triggering GitHub CD pipeline...'

                    withCredentials([string(credentialsId: 'github-credentials', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                        curl -X POST \
                          -H "Authorization: token $GITHUB_TOKEN" \
                          -H "Accept: application/vnd.github.v3+json" \
                          https://api.github.com/repos/Henry-0810/spring-petclinic_DevOps_Project/actions/workflows/cd-deploy.yml/dispatches \
                          -d '{"ref":"main"}'
                        '''
                    }
        }

        failure {
            echo 'Build failed. Sending email and updating GitHub status...'

            // Email notification
            emailext(
                subject: "Jenkins Build FAILED",
                body: "The build has FAILED! Check Jenkins logs for details.",
                to: "munli2002@gmail.com"
            )

            withCredentials([string(credentialsId: 'github-credentials', variable: 'GITHUB_TOKEN')]) {
                sh '''
                curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
                     -H "Accept: application/vnd.github.v3+json" \
                     -d '{"state": "failure", "description": "Jenkins Build Failed!", "context": "continuous-integration/jenkins"}' \
                     https://api.github.com/repos/henry-0810/spring-petclinic_DevOps_Project/statuses/$GIT_COMMIT
                '''
            }

            echo 'CI failed. Skipping GitHub CD trigger.'
        }
    }


}
