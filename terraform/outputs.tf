output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "cert_manager_role_arn" {
  value = module.eks.cert_manager_role_arn
}

output "external_dns_role_arn" {
  value = module.eks.external_dns_role_arn
}
