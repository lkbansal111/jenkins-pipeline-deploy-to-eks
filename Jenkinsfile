#!/usr/bin/env groovy
pipeline {
  agent any
  environment {
    AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    AWS_DEFAULT_REGION    = "us-east-1"
  }
  stages {
    stage("Create/Update EKS") {
      steps {
        script {
          dir('terraform') {
            sh """
              terraform init -upgrade
              terraform apply -auto-approve
            """
            // Read outputs for later stages
            env.CLUSTER_NAME = sh(script: "terraform output -raw cluster_name", returnStdout: true).trim()
            env.NODEGROUP_DEV = sh(script: "terraform output -raw node_group_name_dev", returnStdout: true).trim()
            env.AWS_REGION    = sh(script: "terraform output -raw region", returnStdout: true).trim()

            // Wait for control plane & node group to be fully ACTIVE
            sh """
              aws eks wait cluster-active --name "$CLUSTER_NAME" --region "$AWS_REGION"
              aws eks wait nodegroup-active --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODEGROUP_DEV" --region "$AWS_REGION"
            """

            // Configure kubeconfig and wait for nodes to be Ready
            sh """
              aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"
              # wait up to 10 minutes for nodes to be Ready
              kubectl wait --for=condition=Ready node --all --timeout=600s
            """
          }
        }
      }
    }

    stage("Deploy to EKS") {
      steps {
        script {
          dir('kubernetes') {
            sh """
              aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"
              kubectl apply -f nginx-deployment.yaml
              kubectl apply -f nginx-service.yaml
            """
          }
        }
      }
    }
  }
}
