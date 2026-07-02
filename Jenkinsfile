pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Select Terraform action'
        )
    }

    environment {
        AWS_REGION         = 'ap-south-1'
        AWS_ACCESS_KEY_ID     = credentials('aws-acess-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    options {
        ansiColor('xterm')
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                credentialsId: 'git-credentials',
                url: 'https://github.com/Raghukongala/blu-jenks-terrfrom.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan \
                      -var-file=terraform.tfvars \
                      -out=tfplan \
                      -input=false
                '''
            }
        }

        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                input message: 'Review the plan above. Approve to apply?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh 'terraform apply -input=false -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: 'Are you sure you want to DESTROY all resources?', ok: 'Destroy'
                sh '''
                    terraform destroy \
                      -var-file=terraform.tfvars \
                      -input=false \
                      -auto-approve
                '''
            }
        }
    }

    post {
        success {
            echo "Terraform ${params.ACTION} completed successfully."
        }
        failure {
            echo "Pipeline failed. Check the logs above."
        }
        always {
            cleanWs()
        }
    }
}
