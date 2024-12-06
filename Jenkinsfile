pipeline {
    agent any
    environment {
        registry = "980921731940.dkr.ecr.us-east-1.amazonaws.com/my-reepository"
        BUILD_NUMBER = "${BUILD_NUMBER}"
    }

    stages {
        stage('Building image') {
            steps {
                script {
                    // List files for debugging purposes
                    sh 'ls -la /var/lib/jenkins/workspace/CI'  // Debugging workspace contents

                    // Build Docker image
                    sh "docker build -t ${registry}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Pushing to ECR') {
            steps {
                script {
                    // Log in to ECR using AWS CLI
                    sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 980921731940.dkr.ecr.us-east-1.amazonaws.com'
                    
                    // Push Docker image to ECR
                    sh "docker push ${registry}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Update Deployment File') {
            environment {
                GIT_REPO_NAME = "Task_Tracker"
                GIT_USER_NAME = "hrithiksaini22"
            }
            steps {
                withCredentials([string(credentialsId: 'githubsecret', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                        git config user.email "hrithik9876789@gmail.com"
                        git config user.name "hrithiksaini22"
                       sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" deployment.yaml
                        git add deployment.yaml
                        git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                        git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                    '''
                }
            }
        }
    }

  post {
        // Clean up after the build process
        always {
            // Clean the workspace
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])

            // Clean up Docker containers and volumes (optional)
            sh '''
                # Remove any stopped containers
                docker container prune -f

                # Remove unused Docker volumes
                docker volume prune -f

                # Remove unused networks
                docker network prune -f
            '''
        }
    }
}
