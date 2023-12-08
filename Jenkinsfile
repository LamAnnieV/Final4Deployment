pipeline {
    agent { label 'awsDeploy' }


    stages {
        stage('Build Backend') {
            steps {
                sh 'docker build -t dannydee93/api.net_app -f src/PublicApi/Dockerfile .'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push dannydee93/api.net_app'
            }
        }

        stage('Build Frontend') {
            steps {
                dir('src') {
                    sh 'docker build -t dannydee93/kestrel_web -f src/Web/Dockerfile .'
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    sh 'docker push dannydee93/kestrel_web'
                }
            }
        }

        stage('Deploy to EKS') {
            agent { label 'awsDeploy3' } // or use 'awsDeploy3' if intended
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh "aws eks --region $AWS_EKS_REGION update-kubeconfig --name $AWS_EKS_CLUSTER_NAME"
                        sh "kubectl apply -f $KUBE_MANIFESTS_DIR"
                    }
                }
            }
        }
    }
}
