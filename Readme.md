# Application Deployment: EKS + Terraform + Helm

This project demonstrates how to deploy a microservices-based application on **Amazon Elastic Kubernetes Service (EKS)**. It uses **Terraform** for infrastructure as code and **Helm** for Kubernetes application deployment.

This architecture is designed to be scalable, secure and production-ready.

## Features

- **Infrastructure as Code (IaC)** - Terraform was used to set up VPC, EKS, IAM and ALB.
- **Helm Charts** - used for consistent and repeatable deployments to Kubernetes.

## Documentation

- [Documentation](./documentation/) - step-by-step setup instructions.

---

## Provision Infrastructure with Terraform

Step a: Initialize Terraform

Step b: Validate Configuration

Step c: Apply Configuration

**_Resources Provisioned_**

- VPC
- EKS + Nodegroups
- IAM Roles and Policies
- IAM User
- AWS Load Balancer Controller

## Deploy Helm Charts to EKS

Step a: Configure kubeconfig

Step b: Deploy with Helm

(i) Navigate to the directory of the helm chart (src/app)

(ii) Deploy all services: helm apply

## Configure Ingress (ALB)

Apply the ingress manifest to expose services via AWS ALB:

(i) Navigate to the directory location of the ingress.yaml (src/app/templates)

(ii)Apply the ingress.yaml: kubectl apply -f ingress.yaml

## Verify Deployment

You can then check pods: kubectl get pods -n default

You can also check services: kubectl get svc -n default

## Conclusion

Follow the detailed [Deployment Guide](./documentation/) to set up the infrastructure and deploy the app.
