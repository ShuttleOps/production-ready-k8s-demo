variable "name" {
  type        = string
  description = "The name to use for the EKS Cluster."
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes to use for the EKS Control plane."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnets to place the EKS cluster and workers within."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to deploy the EKS cluster and workers to."
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for the EKS workers."
}

variable "max_size" {
  type        = number
  description = "The maximum size of the EKS worker AutoScalingGroup."
}
