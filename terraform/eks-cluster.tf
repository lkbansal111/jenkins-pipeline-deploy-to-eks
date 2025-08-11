data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                   = "myapp-eks-cluster"
  kubernetes_version     = "1.30"
  endpoint_public_access = true

  vpc_id     = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.private_subnets

  tags = {
    environment = "development"
    application = "myapp"
  }

  # ⬅️ rename this block to `addons`
  addons = {
    vpc-cni   = { most_recent = true }
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }
  }

  eks_managed_node_groups = {
    dev = {
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      capacity_type = "ON_DEMAND"
      instance_types = ["t3.small", "t3a.small"]
      ami_type       = "AL2023_x86_64_STANDARD"
    }
  }

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    node = {
      principal_arn = module.eks.eks_managed_node_groups["dev"].iam_role_arn
      type          = "EC2"
    }
    jenkins_admin = {
      principal_arn = data.aws_caller_identity.current.arn
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
}
