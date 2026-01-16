pipeline {
    agent any

    environment {
        DEV_SERVER   = "ec2-user@DEV_IP"
        STAGE_SERVER = "ec2-user@STAGE_IP"
        PROD_SERVER  = "ec2-user@PROD_IP"
        APP_NAME = "myapp"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${APP_NAME}:${BRANCH_NAME} .
                """
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        deploy(DEV_SERVER, 8081)
                    }
                    else if (env.BRANCH_NAME == 'stage') {
                        deploy(STAGE_SERVER, 8082)
                    }
                    else if (env.BRANCH_NAME == 'main') {
                        deploy(PROD_SERVER, 80)
                    }
                }
            }
        }
    }
}

def deploy(server, port) {
    sh """
    ssh -o StrictHostKeyChecking=no ${server} '
      docker rm -f ${APP_NAME} || true
      docker run -d -p ${port}:80 --name ${APP_NAME} ${APP_NAME}:${BRANCH_NAME}
    '
    """
}
