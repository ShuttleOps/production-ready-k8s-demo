---
webinar: 27/01/2021
---

# Production Kubernetes: Pitfalls to avoid before going live

## Terraform Usage Instructions

1: Apply the predeploy Terraform configuration. You may have to change the s3 bucket name as the names are globally-unique. This will create a backend.tf configuration at the root level of the terraform directory.

2: At the root level of the terraform directory, create a file named `terraform.tfvars` with the following content:
```
iam_users = [
  {
    userarn  = "arn:aws:iam::000000000000:user/jane"
    username = "jane"
    groups   = ["system:masters"]
  },
  {
    userarn  = "arn:aws:iam::000000000000:user/john"
    username = "john"
    groups   = ["system:masters"]
  }
]
```

3: Apply the configuration at the root level of the Terraform directory.

## k8s Usage Instructions

Setting up a kubeconfig for the EKS cluster:

```
$ aws eks --region us-east-2 update-kubeconfig --name production-ready-k8s-demo
```