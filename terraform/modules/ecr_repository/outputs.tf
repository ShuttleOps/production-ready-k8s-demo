output "repository_name" {
  value = aws_ecr_repository.ecr.name
}

output "ci_access_key_id" {
  value = aws_iam_access_key.ecr_ci_iam_user_credentials.id
}

output "ci_secret_access_key" {
  value = aws_iam_access_key.ecr_ci_iam_user_credentials.secret
}
