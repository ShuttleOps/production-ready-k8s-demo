provider "aws" {
  region = "us-east-2"
}

data "aws_region" "current" {
}

locals {
  name = "production-ready-k8s-demo"

  eks_cluster_min_size      = 2
  eks_cluster_max_size      = 2
  eks_cluster_desired_size  = 2
  eks_node_disk_size        = 50
  eks_node_types            = "t3.medium"
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
    Environment = local.name
  }
}

module "eks" {
  source = "./modules/eks_cluster"

  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
  name               = local.name
  max_size           = local.eks_cluster_max_size
  instance_type      = local.eks_node_types
  kubernetes_version = "1.18"
  iam_users          = var.iam_users
}

resource "aws_iam_policy" "cert_manager" {
  name        = "${module.eks.cluster_id}-cert-manager"
  path        = "/"
  description = "Certificate Manager IAM Policy for ${module.eks.cluster_id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cert_manager" {
  name  = "${module.eks.cluster_id}-cert-manager"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "cert_manager" {
  name        = "${module.eks.cluster_id}-cert-manager-attachment"
  policy_arn  = aws_iam_policy.cert_manager.arn
  roles       = [aws_iam_role.cert_manager.name]
}
