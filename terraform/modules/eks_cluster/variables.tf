variable "name" {
  type        = string
  description = "The name to use for the EKS Cluster."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes to use for the EKS Control plane."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "A list of public subnets to configure the EKS control plane against."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of private subnets to put the EKS worker nodes in."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to deploy the EKS cluster and workers to."
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the EKS workers."
}

variable "min_size" {
  type        = number
  description = "The minimum size of the EKS worker AutoScalingGroup."
}

variable "max_size" {
  type        = number
  description = "The maximum size of the EKS worker AutoScalingGroup."
}

variable "desired_size" {
  type        = number
  description = "The desired size of the EKS worker AutoScalingGroup."
}

variable "iam_users" {
  type = list(object({
    userarn = string
    username = string
    groups = list(string)
  }))
  description = "List of IAM users to map in AWS Auth ConfigMap (list of AWS IAM users allowed to interface with EKS control plane)."
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "The ID of the Hosted Zone used for this configuration."
}
