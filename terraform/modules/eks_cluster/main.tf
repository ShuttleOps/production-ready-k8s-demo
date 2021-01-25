data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.2.1"

  cluster_name      = var.name
  cluster_version   = var.kubernetes_version
  subnets           = var.public_subnet_ids
  vpc_id            = var.vpc_id
  write_kubeconfig  = false
  map_users         = var.iam_users

  worker_groups = [
    {
      subnets               = var.private_subnet_ids
      instance_type         = var.instance_type
      asg_max_size          = var.max_size
      asg_min_size          = var.min_size
      asg_desired_capacity  = var.desired_size
    }
  ]
}
