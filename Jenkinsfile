pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Teju-Aws/Terraform.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('Day-2-sample-code') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('Day-2-sample-code') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('Day-2-sample-code') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
