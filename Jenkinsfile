pipeline {
    agent any
    stages {
        stage('Build Images') {
            agent {
                label 'agentDocker'
            }
            steps {
                sh 'sudo chmod 666 /var/run/docker.sock'
                sh 'echo "y" | docker system prune -a'
                sh 'echo "y" | docker volume prune'
                sh 'docker-compose build'
            }
        }
        stage('Login and Push') {
            agent {
                label 'agentDocker'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dannydee93-dockerhub', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW')]) {
                    sh "echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh 'docker push dannydee93/eshopwebmvc:latest'
                    sh 'docker push dannydee93/eshoppublicapi:latest'
                }
            }
        }
        stage('Deploy') {
            agent {
                label 'agentDocker'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dannydee93-dockerhub', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW')]) {
                    sh "echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh 'docker-compose up -d'
                }
            }
        }
    }
}
