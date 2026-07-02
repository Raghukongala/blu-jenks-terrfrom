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
        AWS_REGION      = 'ap-south-1'
        TF_VAR_key_name = credentials('ec2-key-pair-name')   // Jenkins secret text credential
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
                credentialsId: 'git-credentials',        // Jenkins Git credential ID (if private repo)
                url: 'https://github.com/<your-username>/jenkins-terraform.git'  // replace with your repo URL
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'          // Jenkins AWS credential ID
                ]]) {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                        terraform plan \
                          -var-file=terraform.tfvars \
                          -out=tfplan \
                          -input=false
                    '''
                }
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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: 'Are you sure you want to DESTROY all resources?', ok: 'Destroy'
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                        terraform destroy \
                          -var-file=terraform.tfvars \
                          -input=false \
                          -auto-approve
                    '''
                }
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
