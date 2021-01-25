provider "aws" {
  region = "us-east-2"
}

data "aws_region" "current" {
}

locals {
  eks_cluster_min_size      = 2
  eks_cluster_max_size      = 2
  eks_cluster_desired_size  = 2
  eks_node_disk_size        = 50
  eks_node_types            = ["t3.medium"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name = "ecs-fargate-east"
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

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Environment = "dev-east"
  }
}

module "eks" {
  source = "./modules/eks_cluster"

  region             = data.aws_region.current.name
  availability_zones = module.vpc.azs

  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id

  name               = "production-ready-k8s"
  namespace          = "demo"
  stage              = "dev"

  desired_size       = local.eks_cluster_desired_size
  min_size           = local.eks_cluster_min_size
  max_size           = local.eks_cluster_max_size
  disk_size          = local.eks_node_disk_size
  instance_types     = local.eks_node_types
}
