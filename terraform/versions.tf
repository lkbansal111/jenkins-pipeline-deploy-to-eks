terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
}

# Optional: lets the kubernetes provider use the kubeconfig if you need it later
provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}
