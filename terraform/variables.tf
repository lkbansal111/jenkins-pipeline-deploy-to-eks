variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "private_subnet_cidr_blocks" { type = list(string) }
variable "public_subnet_cidr_blocks"  { type = list(string) }
