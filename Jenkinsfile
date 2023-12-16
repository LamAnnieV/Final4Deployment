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
    }
}
