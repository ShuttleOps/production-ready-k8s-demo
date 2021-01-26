variable "iam_users" {
  type = list(object({
    userarn = string
    username = string
    groups = list(string)
  }))
  description = "A list of IAM users to map to the AWS Auth ConfigMap."
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "The ID of the Hosted Zone used for this configuration."
}
