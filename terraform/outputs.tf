output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "external_dns_role_arn" {
  value = module.eks.external_dns_role_arn
}

output "wildcart_cert_arn" {
  value = module.eks.wildcart_cert_arn
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecr_ci_access_key_id" {
  value = module.ecr.ci_access_key_id
}

output "ecr_ci_access_secret_access_key" {
  value = module.ecr.ci_secret_access_key
}
