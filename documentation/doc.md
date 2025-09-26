# Deployment Guide: EKS + Terraform + Helm

This guide describes the end-to-end deployment workflow for running your microservices application on _Amazon EKS_ using _Terraform, **Docker Hub, and **Helm_.

---

## Prerequisites

Ensure you have the following installed locally:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

Authenticate AWS CLI:

```bash
aws configure

```
---

## 1. Provision Infrastructure with Terraform

**Step a: Initialize Terraform**
`terraform init`

**Step b: Validate Configuration**
`terraform validate`

**Step c: Apply Configuration**
`terraform apply -auto-approve`

**_Resources Provisioned_**

- VPC
- EKS + Nodegroups
- IAM Roles and Policies
- IAM User
- AWS Load Balancer Controller

---

## 2. Deploy Helm Charts to EKS

**Step a: Configure kubeconfig**

```bash
aws eks update-kubeconfig --name innovart-eks-cluster --region eu-west-1
```

**Step b: Deploy with Helm**

Navigate to the directory of the helm chart (src/app)

Deploy all services:

```bash
 helm apply
```

---

## 3. Configure Ingress (ALB)

Apply the ingress manifest to expose services via AWS ALB:
Navigate to the directory location of the ingress.yaml (src/app/templates)

```bash
 kubectl apply -f ingress.yaml
```

**_Snippet of the ingress.yaml_**

```yaml
    apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: innovart-app-ingress
  namespace: default
  annotations:
    alb.ingress.kubernetes.io/ingress.alb-id: "arn:aws:elasticloadbalancing:eu-west-1:504178855667:loadbalancer/app/app-lb/ca2ee6c554471169"
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
    alb.ingress.kubernetes.io/listener-rules: |

spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - path: /cart
            pathType: Prefix
            backend:
              service:
                name: carts
                port:
                  number: 80
          - path: /catalog
            pathType: Prefix
            backend:
              service:
                name: catalog
                port:
                  number: 80
          - path: /checkout
            pathType: Prefix
            backend:
              service:
                name: checkout
                port:
                  number: 80
          - path: /orders
            pathType: Prefix
            backend:
              service:
                name: orders
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ui
                port:
                  number: 80
```

---

## 4. Verify Deployment

Check pods:
`kubectl get pods -n default`

Check services:
`kubectl get svc -n default`

---

## Summary

- Terraform provisions AWS infrastructure (EKS, VPC, IAM, ALB Controller)
- Helm deploys microservices (app, cart, catalog, checkout, orders, ui)
