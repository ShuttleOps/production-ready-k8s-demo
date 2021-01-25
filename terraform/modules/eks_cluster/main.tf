data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
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

module "iam_assumable_role_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.7.0"
  create_role                   = true
  role_name                     = "cert-manager-${module.eks.cluster_id}"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
}
