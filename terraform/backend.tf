terraform {
  backend "s3" {
    bucket = "kubernetes-app-111"
    region = "us-east-1"
    key = "eks/terraform.tfstate"
  }
}