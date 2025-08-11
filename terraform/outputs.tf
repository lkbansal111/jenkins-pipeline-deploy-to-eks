output "cluster_name" {
  value = module.eks.cluster_name
}

output "node_group_name_dev" {
  value = module.eks.eks_managed_node_groups["dev"].node_group_name
}

output "region" {
  value = var.region
}
