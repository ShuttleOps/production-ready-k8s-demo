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
route53_zone_id = "EXAMPLEEXAMPLE"
```

3: Apply the configuration at the root level of the Terraform directory.

## k8s-bootstrap Usage Instructions

Set up a kubeconfig for the EKS cluster:

```
$ aws eks --region us-east-2 update-kubeconfig --name production-ready-k8s-demo
```

### Set up ExternalDNS

Install external-dns using kubectl (replace the external dns IAM Role ARN in the manifest with the ARN revealed by running `terraform output`):

```
$ kubectl apply -f k8s-bootstrap/external-dns.yaml
```

### Set up ArgoCD

Install via the official helm chart:

```
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install argocd -n argocd --create-namespace -f k8s-bootstrap/argocd-values.yaml argo/argo-cd
```

Install ArgoCD (on Mac — adjust this step accordingly otherwise):

```
$ brew install argocd
```

Get the initial ArgoCD password (which is the pod name of the API server):

```
$ kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

Get the hostname of the LoadBalancer-type Service for ArgoCD:

```
$ kubectl get svc -n argocd argocd-server -o json | jq -r ".status.loadBalancer.ingress[0].hostname"
```

You can now log into the UI by visiting this endpoint — use the password retrieved earlier.

You can also log into the ArgoCD CLI (getting the hostname of the LoadBalancer-type Service in the process):

```
$ argocd login $(kubectl get svc -n argocd argocd-server -o json | jq -r ".status.loadBalancer.ingress[0].hostname")
```

Enter `y` to proceed despite the invalid certificate name (if you do not have cert-manager set up against a domain); enter the password retrieved earlier.

### Deploy Dummy Application

The dummy application can be deployed via ArgoCD via Helm with its overrides existing in the `k8s-bootstrap/values` directory. When pasting in these overrides, replace the image repository URI with that revealed by running `terraform output`.

### Set up monitoring components

The monitoring components we will set up are:
* prometheus
* prometheus-operator
* alert-manager
* node-exporter
* kube-state-metrics
* grafana

All components can be installed via ArgoCD via Helm with their overrides existing in the `k8s-bootstrap/values` directory. A `fluentd` ConfigMap manifest exists in the `k8s-bootstrap/manifests/fluentd` directory and can be installed in ArgoCD via the git repository (configure the application to use this repository as the upstream source). When pasting any overrides, replace values such as the external-dns host and wildcard ACM ARN revealed by running `terraform output`.
