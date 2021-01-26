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

## k8s-bootstrap Usage Instructions

Set up a kubeconfig for the EKS cluster:

```
$ aws eks --region us-east-2 update-kubeconfig --name production-ready-k8s-demo
```

### Set up ExternalDNS

Install external-dns using kubectl:

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

### Set up monitoring components

The monitoring components we will set up are:
* prometheus
* prometheus-operator
* alert-manager
* node-exporter
* kube-state-metrics
* grafana

All components can be installed via the official community helm chart:

```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm install monitoring -n monitoring --create-namespace -f k8s-bootstrap/kube-prometheus-stack-values.yaml prometheus-community/kube-prometheus-stack
```
