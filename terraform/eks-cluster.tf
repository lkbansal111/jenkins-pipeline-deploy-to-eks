data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                = "myapp-eks-cluster"
  kubernetes_version  = "1.30"
  endpoint_public_access = true

  vpc_id     = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.private_subnets

  tags = {
    environment = "development"
    application = "myapp"
  }

  # Core EKS add-ons (managed automatically, no manual CLI)
  cluster_addons = {
    vpc-cni   = { most_recent = true }
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }
  }

  # Managed node group (Nitro types; 1 node by default)
  eks_managed_node_groups = {
    dev = {
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      capacity_type = "ON_DEMAND"

      instance_types = ["t3.small", "t3a.small"]
      ami_type       = "AL2023_x86_64_STANDARD"

      # The module will create the node role and attach the standard policies.
      # (AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly)
    }
  }

  # Grant Jenkins' AWS principal (the caller) cluster-admin automatically
  enable_cluster_creator_admin_permissions = true

  # Also grant the node role access via EKS Access Entries (replaces manual aws-auth edits)
  access_entries = {
    node = {
      principal_arn = module.eks.eks_managed_node_groups["dev"].iam_role_arn
      type          = "EC2"
      # scope cluster-wide by default; no extra policy needed for nodes
    }

    # (Optional) explicitly grant the Jenkins principal cluster-admin too, if you want to be explicit
    jenkins_admin = {
      principal_arn = data.aws_caller_identity.current.arn
      policy_associations = {
        admin = {
          policy_arn  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
}
