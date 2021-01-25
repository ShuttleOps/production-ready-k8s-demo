module "label" {
  source  = "cloudposse/label/terraform"
  version = "0.5.1"

  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
  tags       = var.tags
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "0.32.0"

  namespace                                 = var.namespace
  stage                                     = var.stage
  name                                      = var.name
  attributes                                = var.attributes
  tags                                      = var.tags
  region                                    = var.region
  vpc_id                                    = var.vpc_id
  subnet_ids                                = var.subnet_ids
  kubernetes_version                        = var.kubernetes_version
  local_exec_interpreter                    = var.local_exec_interpreter
  oidc_provider_enabled                     = var.oidc_provider_enabled
  enabled_cluster_log_types                 = var.enabled_cluster_log_types
  cluster_log_retention_period              = var.cluster_log_retention_period
  map_additional_iam_roles                  = var.map_additional_iam_roles
  map_additional_iam_users                  = var.map_additional_iam_users
  map_additional_aws_accounts               = var.map_additional_aws_accounts
  endpoint_private_access                   = var.endpoint_private_access
  endpoint_public_access                    = var.endpoint_public_access
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.17.1"

  namespace         = var.namespace
  stage             = var.stage
  name              = var.name
  attributes        = var.attributes
  tags              = var.tags
  subnet_ids        = var.subnet_ids
  cluster_name      = module.eks_cluster.eks_cluster_id
  instance_types    = var.instance_types
  desired_size      = var.desired_size
  min_size          = var.min_size
  max_size          = var.max_size
  kubernetes_labels = var.kubernetes_labels
  disk_size         = var.disk_size
}
