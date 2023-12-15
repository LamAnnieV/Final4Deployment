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
                sh 'docker-compose up'
            }
        }
    }
}
