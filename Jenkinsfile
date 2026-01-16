pipeline {
    agent any

    environment {
        APP_NAME     = "myapp"
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
                    echo "Deploying branch ${BRANCH_NAME} to ${TARGET_SERVER}:${PORT}"
                }
            }
        }

        stage('Install Docker on Target Server') {
            steps {
                sh """
                ssh ec2-user@${TARGET_SERVER} '
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

        stage('Build Docker Image on Target Server') {
            steps {
                sh """
                ssh ec2-user@${TARGET_SERVER} '
                cd ~/app || mkdir -p ~/app && cd ~/app
                git clone -b ${BRANCH_NAME} https://github.com/kumbharshubhani-lab/dockermultibranch.git . || (cd dockermultibranch && git pull)
                docker build -t ${APP_NAME}:${BRANCH_NAME} .
                '
                """
            }
        }

        stage('Deploy to Environment') {
            steps {
                sh """
                ssh ec2-user@${TARGET_SERVER}_

