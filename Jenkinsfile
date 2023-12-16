pipeline {
    agent any
    stages {
        stage('Init Terraform') {
            agent {
                label 'agentTerraform'
            }
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    dir('initTerraform') {
                        script {
                            sh 'terraform init'
                            sh 'terraform plan -out plan.tfplan -var="access_key=$aws_access_key" -var="secret_key=$aws_secret_key"'
                            sh 'terraform apply plan.tfplan'
                        }
                    }
                }
            }
        }
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
    }
}
