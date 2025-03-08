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

//         stage('Notify') {
//             steps {
//                 echo 'Sending Slack notification...'
//                 withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
//                     sh '''
//                     curl -X POST --data-urlencode "payload={\\"channel\\": \\"#devops\\", \\"username\\": \\"jenkins\\", \\"text\\": \\"Build successful!\\"}" $SLACK_WEBHOOK
//                     '''
//                 }
//             }
//         }
    }

//     post {
//         failure {
//             echo 'Pipeline failed! Sending failure notification...'
//             withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
//                 sh '''
//                 curl -X POST --data-urlencode "payload={\\"channel\\": \\"#devops\\", \\"username\\": \\"jenkins\\", \\"text\\": \\"Build failed! Check Jenkins logs.\\"}" $SLACK_WEBHOOK
//                 '''
//             }
//         }
//     }
}
