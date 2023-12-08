pipeline {
    agent any

    stages {
        stage('Build Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dannydee93-dockerhub', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW')]) {
                    sh 'docker-compose build'
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    sh 'docker push dannydee93/eshopwebmvc'
                    sh 'docker push dannydee93/eshoppublicapi'
                }
            }
        }

        stage('Deploy to EKS') {
            agent { label 'awsDeploy3' }
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        try {
                            sh "aws eks --region $AWS_EKS_REGION update-kubeconfig --name $AWS_EKS_CLUSTER_NAME"
                            sh "kubectl apply -f $KUBE_MANIFESTS_DIR"
                        } catch (Exception e) {
                            // Handle deployment failure
                            echo "Deployment to EKS failed: ${e.message}"
                            currentBuild.result = 'FAILURE'
                            error(e.message)
                        }
                    }
                }
            }
        }
    }
}
