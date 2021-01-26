output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "external_dns_role_arn" {
  value = module.eks.external_dns_role_arn
}
