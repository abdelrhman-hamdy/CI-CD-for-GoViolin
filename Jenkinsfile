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
        DOCKER_IMAGE_NAME = 'goviolin'
        NEXUS_REPOSITORY = 'nexus:8082'
        NEXUS_PASS = 'admin'
        NEXUS_USER = 'admin'
        KUBECONFIG_PATH = 'connect_jenkins_kubernates/Kubernates_config_for_jenkins'
        DEPLOYMENT_NAME = 'goviolin'
        DEPLOYMENT_NAMESPACE = 'app'
        
    }

    stages {
        stage('Build Docker image') {
            steps {
                script {
                    // Determine the build tag
                    env.DOCKER_IMAGE_TAG = "${NEXUS_REPOSITORY}/${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                    // Build the Docker image
                    sh  "cd ./app; docker build -t ${env.DOCKER_IMAGE_TAG} . "
                }
            }
        }

        stage('Push Docker image to Nexus') {
            steps {
                script {

                        // Push the Docker image to Nexus
                        sh "docker login -u ${NEXUS_USER} -p ${NEXUS_PASS} ${NEXUS_REPOSITORY}"
                        sh "docker push ${env.DOCKER_IMAGE_TAG}"
                    
                }
            }
        }

        stage('Deploy using kubectl') {
            when {
                expression { params.PIPELINE_TYPE == 'build' }
            }
            steps {
                script {
                    // Update the Kubernetes deployment with the new image
                    sh "kubectl --kubeconfig ${KUBECONFIG_PATH} set image deployment/${env.DEPLOYMENT_NAME} ${env.DEPLOYMENT_NAME}=${env.DOCKER_IMAGE_TAG} -n ${env.DEPLOYMENT_NAMESPACE}"
                }
            }
        }

        stage('Check migration') {
            when {
                expression { params.PIPELINE_TYPE == 'build' }
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
