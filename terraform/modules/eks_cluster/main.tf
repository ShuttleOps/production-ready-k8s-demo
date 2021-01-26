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
  enable_irsa       = true

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

resource "aws_iam_policy" "external_dns" {
  name        = "${module.eks.cluster_id}-external-dns"
  path        = "/"
  description = "External DNS IAM Policy for ${module.eks.cluster_id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.7.0"
  create_role                   = true
  role_name                     = "external-dns-${module.eks.cluster_id}"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:external-dns:external-dns"]
}
