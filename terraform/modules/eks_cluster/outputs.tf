output "cluster_id" {
  description = "The name of the cluster"
  value       = module.eks.cluster_id
}

output "external_dns_role_arn" {
  description = "The IAM Role ARN for external-dns"
  value       = module.iam_assumable_role_external_dns.this_iam_role_arn
}
