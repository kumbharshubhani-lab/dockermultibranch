pipeline {
    agent any

    environment {
        APP_NAME = "myapp"
        DEV_SERVER   = "65.2.30.107"
        STAGE_SERVER = "65.0.93.59"
        PROD_SERVER  = "13.232.137.166"
    }

    stages {

        stage('Identify Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        env.TARGET_SERVER = DEV_SERVER
                        env.PORT = "8081"
                    } else if (env.BRANCH_NAME == 'stage') {
                        env.TARGET_SERVER = STAGE_SERVER
                        env.PORT = "8082"
                    } else if (env.BRANCH_NAME == 'main') {
                        env.TARGET_SERVER = PROD_SERVER
                        env.PORT = "8080"
                    } else {
                        error "Unknown branch: ${BRANCH_NAME}"
                    }
                    echo "Deploying branch ${BRANCH_NAME} to ${env.TARGET_SERVER}:${env.PORT}"
                }
            }
        }

        stage('Install Docker on Target Server') {
            steps {
                sh """
                ssh -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no ec2-user@${TARGET_SERVER} '
                    if ! command -v docker &> /dev/null
                    then
                        sudo yum install -y docker
                        sudo systemctl start docker
                        sudo systemctl enable docker
                        sudo usermod -aG docker ec2-user
                    fi
                '
                """
            }
        }

        stage('Copy Code to Target Server') {
            steps {
                sh """
                ssh -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no ec2-user@${TARGET_SERVER} 'mkdir -p ~/myapp'
                scp -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no -r $WORKSPACE/* ec2-user@${TARGET_SERVER}:~/myapp/
                """
            }
        }

        stage('Build Docker Image on Target Server') {
            steps {
                sh """
                ssh -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no ec2-user@${TARGET_SERVER} '
                    cd ~/myapp
                    docker build -t ${APP_NAME}:${BRANCH_NAME} .
                '
                """
            }
        }

        stage('Deploy to Environment') {
            steps {
                sh """
                ssh -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no ec2-user@${TARGET_SERVER} '
                    docker stop ${APP_NAME}-${BRANCH_NAME} || true
                    docker rm ${APP_NAME}-${BRANCH_NAME} || true
                    docker run -d \
                        --name ${APP_NAME}-${BRANCH_NAME} \
                        -p ${PORT}:80 \
                        ${APP_NAME}:${BRANCH_NAME}
                '
                """
            }
        }

    }
}
