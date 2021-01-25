variable "iam_users" {
  type = list(object({
    userarn = string
    username = string
    groups = list(string)
  }))
  description = "A list of IAM users to map to the AWS Auth ConfigMap."
}