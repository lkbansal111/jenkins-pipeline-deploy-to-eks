module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 21.0"
    name = "myapp-eks-cluster"
    kubernetes_version = "1.30"

    endpoint_public_access  = true

    vpc_id = module.myapp-vpc.vpc_id
    subnet_ids = module.myapp-vpc.private_subnets

    tags = {
        environment = "development"
        application = "myapp"
    }

    eks_managed_node_groups = {
        dev = {
            min_size = 1
            max_size = 3
            desired_size = 2
            capacity_type  = "ON_DEMAND"

            instance_types = ["t3.small", "t3a.small"]
        }
    }
}