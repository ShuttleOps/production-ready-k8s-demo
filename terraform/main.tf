provider "aws" {
  region = "us-east-2"
}

data "aws_region" "current" {
}

locals {
  name = "production-ready-k8s-demo"

  eks_cluster_min_size      = 3
  eks_cluster_max_size      = 3
  eks_cluster_desired_size  = 3
  eks_node_disk_size        = 50
  eks_node_types            = "t3.medium"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name = local.name
  cidr = "10.50.0.0/16"

  azs = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"]
  private_subnets = [
    "10.50.1.0/24",
    "10.50.2.0/24",
    "10.50.3.0/24"]
  public_subnets = [
    "10.50.101.0/24",
    "10.50.102.0/24",
    "10.50.103.0/24"]

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Environment = local.name
  }
}

module "eks" {
  source = "./modules/eks_cluster"

  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
  name               = local.name
  min_size           = local.eks_cluster_min_size
  max_size           = local.eks_cluster_max_size
  desired_size       = local.eks_cluster_desired_size
  instance_type      = local.eks_node_types
  kubernetes_version = "1.18"
  iam_users          = var.iam_users
}


