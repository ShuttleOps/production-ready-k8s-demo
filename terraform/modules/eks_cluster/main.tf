module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.22.1"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
  tags       = var.tags
}

module "eks_cluster" {
  source                                    = "git::https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=tags/0.32.0"
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
  kubernetes_config_map_ignore_role_changes = var.kubernetes_config_map_ignore_role_changes
  map_additional_iam_roles                  = var.map_additional_iam_roles
  map_additional_iam_users                  = var.map_additional_iam_users
  map_additional_aws_accounts               = var.map_additional_aws_accounts
  endpoint_private_access                   = var.endpoint_private_access
  endpoint_public_access                    = var.endpoint_public_access
}

# Ensure ordering of resource creation to eliminate the race conditions when applying the Kubernetes Auth ConfigMap.
# Do not create Node Group before the EKS cluster is created and the `aws-auth` Kubernetes ConfigMap is applied.
# Otherwise, EKS will create the ConfigMap first and add the managed node role ARNs to it,
# and the kubernetes provider will throw an error that the ConfigMap already exists (because it can't update the map, only create it).
# If we create the ConfigMap first (to add additional roles/users/accounts), EKS will just update it by adding the managed node role ARNs.
data "null_data_source" "wait_for_cluster_and_kubernetes_configmap" {
  inputs = {
    cluster_name             = module.eks_cluster.eks_cluster_id
    kubernetes_config_map_id = module.eks_cluster.kubernetes_config_map_id
  }
}

module "eks_node_group" {
  source            = "git::https://github.com/cloudposse/terraform-aws-eks-node-group.git?ref=tags/0.17.1"
  namespace         = var.namespace
  stage             = var.stage
  name              = var.name
  attributes        = var.attributes
  tags              = var.tags
  subnet_ids        = var.subnet_ids
  cluster_name      = data.null_data_source.wait_for_cluster_and_kubernetes_configmap.outputs["cluster_name"]
  instance_types    = var.instance_types
  desired_size      = var.desired_size
  min_size          = var.min_size
  max_size          = var.max_size
  kubernetes_labels = var.kubernetes_labels
  disk_size         = var.disk_size
}
