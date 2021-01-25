output "cluster_id" {
  description = "The name of the cluster"
  value       = module.eks.cluster_id
}

output "cert_manager_role_arn" {
  description = "The IAM Role ARN for cert-manager"
  value       = module.iam_assumable_role_cert_manager.this_iam_role_arn
}
