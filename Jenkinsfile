pipeline {
    agent any

    parameters {
        choice(name: 'PIPELINE_TYPE', choices: ['build', 'Test'], description: 'Select the type of pipeline to run')
    }

    environment {
        DOCKER_TLS_VERIFY="1"
        DOCKER_HOST="tcp://192.168.49.2:2376"
        DOCKER_CERT_PATH="/var/jenkins_home/docker"
        DOCKERFILE_PATH = 'app/Dockerfile'
        DOCKER_IMAGE_NAME = 'GoViolin'
        NEXUS_REPOSITORY = 'nexus:8082'
        NEXUS_CREDENTIALS = 'nexus-credentials-id'
        KUBECONFIG_PATH = 'path/to/kubeconfig'
        DEPLOYMENT_NAME = 'goviolin'
        DEPLOYMENT_NAMESPACE = 'goviolin'
    }

    stages {
        stage('Build Docker image') {
            steps {
                script {
                    // Determine the build tag
                    env.DOCKER_IMAGE_TAG = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                    // Build the Docker image
                    sh "docker build -t ${NEXUS_REPOSITORY}/${env.DOCKER_IMAGE_TAG} -f ${env.DOCKERFILE_PATH} ."
                }
            }
        }

        stage('Push Docker image to Nexus') {
            steps {
                script {
                    docker.withRegistry("${env.NEXUS_REPOSITORY}", "${env.NEXUS_CREDENTIALS}") {
                        // Push the Docker image to Nexus
                        sh "docker push ${NEXUS_REPOSITORY}/${env.DOCKER_IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy using kubectl') {
            when {
                expression { params.PIPELINE_TYPE == 'Test' }
            }
            steps {
                script {
                    // Update the Kubernetes deployment with the new image
                    sh "kubectl --kubeconfig ${env.KUBECONFIG_PATH} set image deployment/${env.DEPLOYMENT_NAME} ${env.DEPLOYMENT_NAME}=${env.DOCKER_IMAGE_TAG} -n ${env.DEPLOYMENT_NAMESPACE}"
                }
            }
        }

        stage('Check migration') {
            when {
                expression { params.PIPELINE_TYPE == 'Test' }
            }
            steps {
                script {
                    // Check if the migration was successful
                    def migrationCheck = sh(script: "kubectl --kubeconfig ${env.KUBECONFIG_PATH} rollout status deployment/${env.DEPLOYMENT_NAME} -n ${env.DEPLOYMENT_NAMESPACE}", returnStatus: true)

                    if (migrationCheck != 0) {
                        error("Migration failed. Please check the logs.")
                    } else {
                        echo("Migration successful.")
                    }
                }
            }
        }
    }
}
